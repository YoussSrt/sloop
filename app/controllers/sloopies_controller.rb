class SloopiesController < ApplicationController
  before_action :set_sloopy, only: [:show, :update_save, :update_status, :destroy]


  def index
    @sloopies = if user_signed_in?
                  current_user.sloopies.where(is_saved: false).order(created_at: :desc).limit(1)
                else
                  Sloopy.none
                end

    @markers = @sloopies.flat_map.with_index do |sloopy, index|
      Rails.logger.info "Processing sloopy #{sloopy.id} for markers"
      sloopy.to_markers(index)
    end

    respond_to do |format|
      format.html
      format.json { render json: @markers }
    end
    Rails.logger.info "Final markers for index: #{@markers.inspect}"
  end

  def show
    @sloopy = Sloopy.find(params[:id])
    # @review = @sloopy.reviews.new
    @question = Question.new
    @markers = []
    route_coordinates = []

    # Point de départ
    if @sloopy.origin_latitude.present? && @sloopy.origin_longitude.present?
      route_coordinates << [@sloopy.origin_longitude, @sloopy.origin_latitude]
      @markers << {
        lat: @sloopy.origin_latitude,
        lng: @sloopy.origin_longitude,
        type: "origin"
      }
    end

    # Étapes
    @sloopy.steps.each do |step|
      if step.latitude.present? && step.longitude.present?
        route_coordinates << [step.longitude, step.latitude]
        @markers << {
          lat: step.latitude,
          lng: step.longitude,
          type: "step"
        }
      end
    end

    # Point d'arrivée
    if @sloopy.destination_latitude.present? && @sloopy.destination_longitude.present?
      route_coordinates << [@sloopy.destination_longitude, @sloopy.destination_latitude]
      @markers << {
        lat: @sloopy.destination_latitude,
        lng: @sloopy.destination_longitude,
        type: "destination"
      }
    end

    # Fermer la boucle
    route_coordinates << route_coordinates.first if route_coordinates.any?

    # Ajouter les coordonnées du tracé au premier marqueur
    @markers.first[:route_coordinates] = route_coordinates if @markers.any?
    @markers.first[:route_id] = 0 if @markers.any? # Un seul tracé dans la vue show
  end

  def new
    @sloopy = Sloopy.new
  end

  def steps
    steps = JSON.parse(@sloopy.steps)
  end

  def create
    Sloopy.where(user: current_user, is_saved: false).destroy_all

    @sloopy = Sloopy.new(sloopy_params)
    @sloopy.user = current_user
    @sloopy.departure_date = sloopy_params[:departure_date].split("to").first
    @sloopy.return_date = sloopy_params[:departure_date].split("to").last
    formatted_preferences = current_user.formatted_preferences

    if @sloopy.save
      current_index = current_user.sloopies.length - 1

      # Afficher immédiatement la card en chargement
      # Turbo::StreamsChannel.broadcast_append_to(
      #   "sloopies",
      #   target: "sloopies",
      #   partial: "sloopies/loading_card",
      #   locals: { sloopy: @sloopy, index: current_index }
      # )

      # Lancer la génération en arrière-plan
      GenerateSloopyJob.perform_later(@sloopy, formatted_preferences, current_index)
      redirect_to sloopies_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @sloopy = Sloopy.find(params[:id])
    @sloopy.destroy!
    redirect_to profile_path, status: :see_other
  end

  def update_save
    @sloopy.is_saved = true # Toujours sauvegarder, ne pas toggler

    if @sloopy.save
      redirect_to request.referer, notice: "Sloopy saved!"
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("save-status-#{@sloopy.id}", partial: "sloopies/save_status", locals: { sloopy: @sloopy }) }
        format.html { redirect_to request.referer, alert: "Unable to save Sloopy." }
      end
    end
  end

  def update_status
    # Ensure @sloopy is properly set here
    if @sloopy.nil?
      redirect_to profile_path, alert: "Sloopy not found."  # Redirection vers profile_path si le sloopy n'est pas trouvé
      return
    end

    # Toggle the status of sloopy between 'done' and 'in_progress'
    @sloopy.update(status: @sloopy.status == 'done' ? 'in_progress' : 'done')

    if @sloopy.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("status-toggle-form-#{@sloopy.id}", partial: "sloopies/status_button", locals: { sloopy: @sloopy }),
            turbo_stream.replace("status-text-#{@sloopy.id}", partial: "sloopies/status_text", locals: { sloopy: @sloopy })
          ]
        end
        # Redirection vers profile_path après la mise à jour du statut
        format.html { redirect_to profile_path, notice: "Sloopy status updated!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("status-text-#{@sloopy.id}", partial: "sloopies/status_text", locals: { sloopy: @sloopy })
        end
        # Redirection vers profile_path même si la mise à jour échoue
        format.html { redirect_to profile_path, alert: "Unable to update status." }
      end
    end
  end




  def copy
    @original_sloopy = Sloopy.find(params[:id])

    # Créer une nouvelle instance du Sloopy pour l'utilisateur actuel
    @sloopy_copy = @original_sloopy.dup
    @sloopy_copy.user_id = current_user.id
    @original_sloopy.steps.each do |step|
      new_step = step.dup
      new_step.sloopy = @sloopy_copy
      new_step.save
    end
    @sloopy_copy.is_saved = true
    @sloopy_copy.copy = true

    # Sauvegarder la copie
    if @sloopy_copy.save
      respond_to do |format|
        format.html { redirect_to profile_path, notice: 'Sloopy copied successfully!' }
        format.js   { render turbo_stream: turbo_stream.replace("btn-copy-toggle-#{@original_sloopy.id}", partial: "sloopies/save_button", locals: { sloopy: @sloopy_copy }) }
      end
    else
      redirect_to sloopies_path, alert: 'Failed to copy Sloopy.'
    end
  end



  private

  def sloopy_params
    params.require(:sloopy).permit(:origin, :destination, :departure_date, :return_date, :budget, :duration, :status, :is_saved)
  end

  def set_coordinates
    if origin.present?
      coords = Geocoder.search(origin).first&.coordinates
      if coords
        self.origin_latitude, self.origin_longitude = coords
      end
    end
    if destination.present?
      coords = Geocoder.search(destination).first&.coordinates
      if coords
        self.destination_latitude, self.destination_longitude = coords
      end
    end
  end

  def geocode_origin
    geocode_address(:origin, :origin_latitude, :origin_longitude)
  end

  def geocode_destination
    geocode_address(:destination, :destination_latitude, :destination_longitude)
  end

  def geocode_address(attribute, latitude_attribute, longitude_attribute)
    results = Geocoder.search(self.send(attribute))
    if results.present?
      coordinates = results.first.coordinates
      self.send("#{latitude_attribute}=", coordinates[0])
      self.send("#{longitude_attribute}=", coordinates[1])
    end
  end

  def set_sloopy
    @sloopy = Sloopy.find(params[:id])
  end

  def set_sloopy
    @sloopy = Sloopy.find_by(id: params[:id]) # Use `find_by` to avoid exceptions if not found
    if @sloopy.nil?
      redirect_to sloopies_path, alert: "Sloopy not found."
    end
  end
end

def disable_caching
  response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
end
