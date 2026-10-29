# Counts the SQL queries Active Record runs while a block executes, grouped by
# the name Rails prints in the server log ("User Load", "Comment Count", ...).
module QueryCounter
  def count_queries
    counts = Hash.new(0)
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
      next if payload[:name].nil? || payload[:name] == "SCHEMA" || payload[:cached]
      counts[payload[:name]] += 1
    end
    yield
    counts
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  def seed_photos(count: 25)
    users = 5.times.map { |i| User.create!(username: "user#{i}", email: "user#{i}@example.com", password: "appdev") }
    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
    count.times do |i|
      photo = Photo.new(caption: "Photo #{i}", owner: users[i % users.size])
      photo.image.attach(io: StringIO.new(png), filename: "photo#{i}.png", content_type: "image/png")
      photo.save!
      2.times { |j| Comment.create!(photo: photo, author: users[(i + j + 1) % users.size], body: "Comment #{j}") }
    end
    users.first
  end
end

module QueryCounter
  include Warden::Test::Helpers

  # Sign a user in for feature specs without going through the sign-in form.
  def sign_in(user)
    login_as(user, scope: :user)
  end
end

RSpec.configure do |config|
  config.include QueryCounter
  config.after(:each) { Warden.test_reset! }

  # The first Active Storage URL built in a fresh test process trips a
  # respond_to? recursion (SystemStackError) in Rails 8.1 before the attachment
  # classes are fully loaded. Build one URL up front so no example pays for it.
  config.before(:suite) do
    begin
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("warmup"), filename: "warmup.txt", content_type: "text/plain")
      Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
      blob.purge
    rescue SystemStackError, StandardError
      nil
    end
  end
end
