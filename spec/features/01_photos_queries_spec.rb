require "rails_helper"
require "support/query_counter"

describe "/photos" do
  it "loads the owners of 25 photos with one query, not one per photo", points: 2, hint: h("eager_load_owner") do
    user = seed_photos
    sign_in(user)

    counts = count_queries { visit "/photos" }

    expect(counts["User Load"]).to be <= 2,
      "Expected at most 2 'User Load' queries while rendering /photos, but there were #{counts["User Load"]}. Each photo's owner is being looked up one at a time."
  end

  it "reads each photo's comment count from the counter cache column, with no COUNT queries", points: 2, hint: h("counter_cache") do
    user = seed_photos
    sign_in(user)

    counts = count_queries { visit "/photos" }

    expect(counts["Comment Count"]).to eq(0),
      "Expected no 'Comment Count' (SELECT COUNT(*)) queries while rendering /photos, but there were #{counts["Comment Count"]}. The template is still calling .count on each photo's comments."
  end

  it "loads the photos' image attachments up front, not one per photo", points: 2, hint: h("attached_image") do
    user = seed_photos
    sign_in(user)

    counts = count_queries { visit "/photos" }

    expect(counts["ActiveStorage::Attachment Load"]).to be <= 4,
      "Expected the image attachments for /photos to be loaded in one query, but there were #{counts["ActiveStorage::Attachment Load"]} 'ActiveStorage::Attachment Load' queries."
  end

  it "renders 25 photos in fewer than 15 queries altogether", points: 2, hint: h("query_total") do
    user = seed_photos
    sign_in(user)

    counts = count_queries { visit "/photos" }
    total = counts.values.sum

    expect(total).to be < 15,
      "Expected /photos to render 25 photos in fewer than 15 queries, but it took #{total}: #{counts.sort_by { |_, n| -n }.first(4).map { |n, c| "#{c} × #{n}" }.join(", ")}."
  end
end
