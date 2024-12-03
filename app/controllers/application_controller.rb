class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :nickname])
  end

  private
  def set_current_user
    Current.user = current_user
  end
end
