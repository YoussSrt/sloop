# class ReviewsController < ApplicationController
#   before_action :set_sloopy, only: [:new, :create]
#   before_action :set_review_from_id, only: [:new, :create, :edit, :update, :destroy]
  
#   def new
#     @review = @sloopy.reviews.new
#   end
  
#   def create
#     @review = @sloopy.reviews.new(review_params)
#     if @review.save
#       redirect_to review_path(@review)
#       # redirect_to sloopy_path(@sloopy), notice: 'Review successfully created!'
#     else
#       render :new
#     end
#   end

#   def show
#   end
  
#   def edit
#   end
  
#   def update
#     if @review.update(review_params)
#       # redirect_to sloopy_path(@sloopy), notice: 'Review successfully updated!'
#       redirect_to review_path(@review)
#     else
#       render :edit
#     end
#   end
  
#   def destroy
#     @review.destroy
#     sloopy = @review.sloopy
#     redirect_to new_sloopy_review_path(sloopy)
#     redirect_to sloopy_path(@sloopy), notice: 'Review successfully deleted!'
#     # redirect_to new_review_path(@review)

#   end
  
#   private
  
#   def set_sloopy
#     @sloopy = Sloopy.find(params[:sloopy_id])
#   end
  
#   def set_review
#     @review = @sloopy.reviews.find(params[:id])
#     unless @review
#       flash[:alert] = "Review not found."
#       redirect_to sloopy_path(params[:sloopy_id]) 
#     end
#   end

#   def set_review_from_id
#     @review = Review.find_by(id: params[:id])
#   end
  
#   def review_params
#     params.require(:review).permit(:content, :rating)
#   end
# end
