class ChatMessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    logger.info params[:browser_info]
    @message = ChatMessage.new(message_params)
    authorize_action_for @message
    if @message.save
      render "create"
    else 
      render "creation_error"
    end
  end

  private 

    def message_params
      params.require(:chat_message).permit(:content, :chat_id).merge(user: current_user)
    end
end
