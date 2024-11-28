class SloopiesController < ApplicationController
  def index
    @sloopies = Sloopy.all
    @markers = @sloopies.flat_map do |sloopy|
      [
        {
          lat: sloopy.origin_latitude,
          lng: sloopy.origin_longitude,
          info_window_html: render_to_string(partial: "info_window", locals: { sloopy: sloopy })
        },
        {
          lat: sloopy.destination_latitude,
          lng: sloopy.destination_longitude,
          info_window_html: render_to_string(partial: "info_window", locals: { sloopy: sloopy })
        }
      ]
    end
  end

  def show
    @sloopy = Sloopy.find(params[:id])
    @markers = [
      {
        lat: @sloopy.origin_latitude,
        lng: @sloopy.origin_longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { sloopy: @sloopy, location: @sloopy.origin }),
        marker_html: render_to_string(partial: "marker", locals: { marker_type: "origin" })
      },
      {
        lat: @sloopy.destination_latitude,
        lng: @sloopy.destination_longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { sloopy: @sloopy, location: @sloopy.destination }),
        marker_html: render_to_string(partial: "marker", locals: { marker_type: "destination" })
      }
    ]
  end

  def new
    @sloopy = Sloopy.new
  end

  def steps
    steps = JSON.parse(@sloopy.steps)
  end

  def create
    @sloopy = Sloopy.new(sloopy_params)
    @sloopy.user = current_user

    open_ai_service = OpenAiService.new(@sloopy).call
    if @sloopy.save
      redirect_to sloopies_path, notice: "Sloopy itinerary generated successfully!"
    else
      render :new
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
end
