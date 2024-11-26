class SloopiesController < ApplicationController
  def index
    @sloopies = policy_scope(Sloopy)
  end

  def show
    # @sloopy = Sloopy.find_by(id: params[:id])
    authorize @sloopy
  end

  def new
    @sloopy = Sloopy.new
    authorize @sloopy
  end

  def create
    @sloopy = Sloopy.new(sloopy_params)
    @sloopy.user = current_user
    authorize @sloopy
  end
end
