class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom, only: [:show]

  def index
    @chatrooms = Chatroom.where("first_user_id = :id OR second_user_id = :id", id: current_user.id)
    first_chatroom = @chatrooms.first
    redirect_to first_chatroom ? chatroom_path(first_chatroom) : root_path
  end
  
  def show
    @chatroom = Chatroom.find(params[:id])
    @message = Message.new
    @users = User.where.not(id: current_user.id)
    @chatrooms = Chatroom.where("first_user_id = :id OR second_user_id = :id", id: current_user.id)
                        .left_joins(:messages)
                        .group("chatrooms.id")
                        .select("chatrooms.*, COALESCE(MAX(messages.created_at), chatrooms.created_at) as last_message_time")
                        .order("last_message_time DESC")
  end



  def create
    first_user = current_user
    second_user = User.find(params[:second_user_id])

    @chatroom = Chatroom.between_users(first_user, second_user).first_or_create!(
      first_user: first_user,
      second_user: second_user
    )

    redirect_to chatroom_path(@chatroom)
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find(params[:id])
    unless @chatroom.first_user == current_user || @chatroom.second_user == current_user
      redirect_to root_path, alert: "You don't have access to this chat"
    end
  end
end
