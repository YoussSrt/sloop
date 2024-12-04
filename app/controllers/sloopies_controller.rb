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

    Rails.logger.info "Final markers for index: #{@markers.inspect}"
  end

  def show
    @sloopy = Sloopy.find(params[:id])
    @review = @sloopy.reviews.new
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
      redirect_to sloopies_path, notice: 'Generating your Sloopy...'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @sloopy = Sloopy.find(params[:id])
    @sloopy.destroy
    redirect_to sloopies_path, status: :see_other
  end

  def update_save
    @sloopy.is_saved = !@sloopy.is_saved

    if @sloopy.save
      respond_to do |format|
        format.turbo_stream do
          if @sloopy.is_saved
            # Quand on sauvegarde un sloopy
            render turbo_stream: [
              turbo_stream.remove("sloopy_#{@sloopy.id}"),
              turbo_stream.append("sloopies-grid", partial: "sloopies/profile_card", locals: { sloopy: @sloopy }),
              turbo_stream.update("sloopies-count", @sloopy.user.sloopies.where(is_saved: true).count)
            ]
          else
            # Quand on retire un sloopy des sauvegardés
            render turbo_stream: [
              turbo_stream.remove("sloopy_#{@sloopy.id}"),
              turbo_stream.update("sloopies-count", @sloopy.user.sloopies.where(is_saved: true).count)
            ]
          end
        end
        format.html { redirect_to request.referer, notice: "Sloopy #{@sloopy.is_saved ? 'saved' : 'unsaved'}!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("save-status-#{@sloopy.id}", partial: "sloopies/save_status", locals: { sloopy: @sloopy }) }
        format.html { redirect_to request.referer, alert: "Unable to update save status." }
      end
    end
  end


  def update_status
    if @sloopy.nil?
      redirect_to sloopies_path, alert: "Sloopy not found."
      return
    end

    @sloopy.status = 'completed'

    if @sloopy.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("sloopy_card_#{@sloopy.id}"),
            turbo_stream.prepend("realized_sloopies", 
              partial: "sloopies/realized_card", 
              locals: { sloopy: @sloopy }
            )
          ]
        end
        format.html { redirect_to profile_path, notice: "Sloopy marked as completed!" }
      end
    else
      redirect_to profile_path, alert: "Unable to update status."
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
