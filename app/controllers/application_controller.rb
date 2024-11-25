class ApplicationController < ActionController::Base
  before_action :authenticate_user! # S'assure que l'utilisateur est authentifié avant chaque action
  include Pundit::Authorization # Inclut le module de gestion des autorisations Pundit

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit? # Vérifie que l'utilisateur est autorisé après chaque action sauf index
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit? # Vérifie que la politique est bien appliquée pour la vue index

  # Décommentez lorsque vous *comprenez vraiment* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/ # Permet d'éviter Pundit dans certains cas
  end
end
