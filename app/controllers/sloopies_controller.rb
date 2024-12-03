class SloopiesController < ApplicationController
  before_action :set_sloopy, only: [:show, :update_save, :destroy]


  def index
    @sloopies = if user_signed_in?
                  current_user.sloopies
                else
                  Sloopy.all
                end

    @markers = @sloopies.flat_map.with_index do |sloopy, index|
      route_coordinates = []
      markers = []

      # Départ
      if sloopy.origin_latitude && sloopy.origin_longitude
        route_coordinates << [sloopy.origin_longitude, sloopy.origin_latitude]
        markers << { lat: sloopy.origin_latitude, lng: sloopy.origin_longitude, type: "origin" }
      end

      # Étapes
      sloopy.steps.each do |step|
        if step.latitude && step.longitude
          route_coordinates << [step.longitude, step.latitude]
          markers << { lat: step.latitude, lng: step.longitude, type: "step" }
        end
      end

      # Arrivée
      if sloopy.destination_latitude && sloopy.destination_longitude
        route_coordinates << [sloopy.destination_longitude, sloopy.destination_latitude]
        markers << { lat: sloopy.destination_latitude, lng: sloopy.destination_longitude, type: "destination" }
      end

      # Fermer la boucle en ajoutant le point de départ à la fin
      if route_coordinates.any?
        route_coordinates << route_coordinates.first
      end

      markers.first[:route_coordinates] = route_coordinates if markers.any?
      markers.first[:route_id] = index if markers.any?
      markers
    end
  end

  def show
    @sloopy = Sloopy.find(params[:id])
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
      current_index = current_user.sloopies.length
      GenerateSloopyJob.perform_later(@sloopy, formatted_preferences, current_index)
      redirect_to sloopies_path, notice: 'Job was successfully created.'
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
          # Mettre à jour les éléments nécessaires avec turbo_stream
          render turbo_stream: [
            turbo_stream.replace("save-status-#{@sloopy.id}", partial: "sloopies/save_status", locals: { sloopy: @sloopy }),
            turbo_stream.replace("btn-save-toggle-#{@sloopy.id}", partial: "sloopies/save_button", locals: { sloopy: @sloopy })
          ]
        end
        format.html { redirect_to request.referer, notice: "Sloopy save status updated!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("save-status-#{@sloopy.id}", partial: "sloopies/save_status", locals: { sloopy: @sloopy })
        end
        format.html { redirect_to request.referer, alert: "Unable to update save status." }
      end
    end
  end

  private

  def sloopy_params
    params.require(:sloopy).permit(:origin, :destination, :departure_date, :return_date, :budget, :duration)
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
end
