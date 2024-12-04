class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  before_action :authenticate_user!

  def home
    @sloopy = Sloopy.new
    @sloopy.budget = 500 # Valeur par défaut au milieu de la plage (0-1500)
  end

  def profile
    @user = current_user
  end

  def other_user_profile
    @user = User.find(params[:id])  # Trouve l'utilisateur par son ID
  end

  # def feed
  #   # @user = current_user  # Définit l'utilisateur connecté dans la variable @user
  #   # @sloopies = Sloopy.all # Ou toute autre logique pour récupérer les Sloopies
  # end


  def feed
  #  @user = User.find(params[:id])
    if user_signed_in? # Vérifie si un utilisateur est connecté
      @sloopies = Sloopy.where.not(user_id: current_user.id) # Exclut les sloops créés par l'utilisateur actuel
                         .order(created_at: :desc)         # Trie par date de création (plus récents d'abord)
    else
      @sloopies = Sloopy.none # Si aucun utilisateur connecté, aucun sloops à afficher
    end
  end
end
