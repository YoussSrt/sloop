class MessagesController < ApplicationController
  def create
    @chatroom = Chatroom.find(params[:chatroom_id])
    @message = @chatroom.messages.new(message_params.merge(sender: current_user))
    
    if @message.save
      # Le broadcast est géré par le modèle, pas besoin de format.turbo_stream
      head :ok
    else
      render "chatrooms/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
