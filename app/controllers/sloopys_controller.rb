class SloopysController < ApplicationController
  def index
    @sloopies = Sloopys.all
  end

end
