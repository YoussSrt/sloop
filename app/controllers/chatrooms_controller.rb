class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom, only: [:show]

  def show
    @message = Message.new
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find(params[:id])
    unless @chatroom.first_user == current_user || @chatroom.second_user == current_user
      redirect_to root_path, alert: "You don't have access to this chat"
    end
  end
end
