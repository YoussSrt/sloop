class SloopiesController < ApplicationController
  def index
    if user_signed_in?
      @sloopies = current_user.sloopies
    else
      @sloopies = []
    end
  end

  def show
    @sloopy = Sloopy.find(params[:id])
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
    @sloopy.departure_date = sloopy_params[:departure_date].split("to").first
    @sloopy.return_date = sloopy_params[:departure_date].split("to").last

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
end
