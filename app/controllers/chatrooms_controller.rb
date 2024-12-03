class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom, only: [:show]

  def index
    first_chatroom = Chatroom.where("first_user_id = :id OR second_user_id = :id", id: current_user.id).first
    redirect_to first_chatroom ? chatroom_path(first_chatroom) : root_path
  end
  
  def show
    @chatroom = Chatroom.find(params[:id])
    @message = Message.new
    @users = User.where.not(id: current_user.id)
    @chatrooms = Chatroom.where("first_user_id = :user_id OR second_user_id = :user_id", user_id: current_user.id)
  end



  def create
    second_user = User.find(params[:second_user_id])
    @chatroom = Chatroom.new(first_user: current_user, second_user: second_user)

    if @chatroom.save
      redirect_to chatroom_path(@chatroom)
    else
      redirect_to root_path, alert: "Impossible de créer la conversation"
    end
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find(params[:id])
    unless @chatroom.first_user == current_user || @chatroom.second_user == current_user
      redirect_to root_path, alert: "You don't have access to this chat"
    end
  end
end
