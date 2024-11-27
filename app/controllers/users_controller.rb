class UsersController < ApplicationController
  before_action :authenticate_user! 

  def update_preferences
    current_user.update_preferences(preferences_params)
    redirect_to sloopies_path, notice: "Your preferences were updated successfully"
  end

  private

  def preferences_params
    params.require(:preferences).permit(
      favorite_activities: [],
      ideal_travel_pace: [],
      exciting_experiences: [],
      traveling_with: [],
      preferred_vibe: [],
      main_travel_goal: []
    )
  end
end

