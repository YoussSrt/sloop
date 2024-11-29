class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @sloopy = Sloopy.new
  end

  def profile
    @user = current_user
  end
end
