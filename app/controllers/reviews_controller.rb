class ReviewsController < ApplicationController
  before_action :set_sloopy
  before_action :set_review, only: [:edit, :update, :destroy]
  
  def new
    @review = @sloopy.reviews.new
  end
  
  def create
    @review = @sloopy.reviews.new(review_params)
    if @review.save
      redirect_to sloopy_path(@sloopy), notice: 'Review successfully created!'
    else
      render :new
    end
  end
  
  def edit

  end
  
  def update
    if @review.update(review_params)
      redirect_to sloopy_path(@sloopy), notice: 'Review successfully updated!'
    else
      render :edit
    end
  end
  
  def destroy
    @review.destroy
    redirect_to sloopy_path(@sloopy), notice: 'Review successfully deleted!'
  end
  
  private
  
  def set_sloopy
    @sloopy = Sloopy.find(params[:sloopy_id])
  end
  
  def set_review
    @review = @sloopy.reviews.find(params[:id])
  end
  
  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
