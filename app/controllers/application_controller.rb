class ApplicationController < ActionController::Base
  before_action :authenticate_user!


  before_action :configure_permitted_parameters, if: :devise_controller?

  # Décommentez lorsque vous *comprenez vraiment* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :nickname])
  end


end
