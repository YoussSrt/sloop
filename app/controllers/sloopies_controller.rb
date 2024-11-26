class SloopiesController < ApplicationController
  def index
    @sloopies = Sloopy.all
  end

  def show
    @sloopy = Sloopy.find_by(id: params[:id])
  end

  def new
    @sloopy = Sloopy.new
  end

  def create
    @sloopy = Sloopy.new(sloopy_params)
    @sloopy.user = current_user
  end
end
