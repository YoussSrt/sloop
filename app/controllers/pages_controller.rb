class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @sloopy = Sloopy.new
    @sloopy.budget = 750 # Valeur par défaut au milieu de la plage (0-1500)
  end

  def profile
    @user = current_user
  end
end
