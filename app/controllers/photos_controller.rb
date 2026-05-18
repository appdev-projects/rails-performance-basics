class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show edit likes update destroy ]

  def index
    @photos = Photo.all.limit(25)
    render layout: false
  end

  # GET /photos/1 or /photos/1.json
  def show
    authorize! @photo
  end

  def likes
    @likes = @photo.likes
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
    authorize! @photo
  end

  # POST /photos or /photos.json
  def create
    @photo = Photo.new(photo_params)
    @photo.owner = current_user

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: "Photo was successfully created." }
        format.json { render :show, status: :created, location: @photo }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photos/1 or /photos/1.json
  def update
    authorize! @photo
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: "Photo was successfully updated." }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1 or /photos/1.json
  def destroy
    authorize! @photo
    @photo.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Photo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.expect(photo: [:image, :pinned, :caption])
    end
end
