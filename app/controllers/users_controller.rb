class UsersController < ApplicationController
  before_action :authenticate_user! 
  

  def edit_preferences
    

  end

  def update_preferences
    current_user.update_preferences(preferences_params)

      redirect_to sloopies_path, anchor: "#form_new_sloop", notice: "Your preferences were updated successfully"
 
  end

  private

  def preferences_params
    params.require(:user_preferences).permit(
      favorite_activities: [],
      ideal_travel_pace: [],
      exciting_experiences: [],
      traveling_with: [],
      preferred_vibe: [],
      main_travel_goal: []
    )
  end
end

