# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  # Override the destroy method to delete unsaved sloopy records before logout
  def destroy
    # Supprimer tous les Sloopies avec is_saved = false avant de se déconnecter
    current_user.sloopies.where(is_saved: false).destroy_all

    # Appeler la méthode destroy de Devise pour effectuer la déconnexion
    super
  end
end
