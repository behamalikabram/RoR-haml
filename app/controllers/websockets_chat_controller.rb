class WebsocketsChatController < WebsocketRails::BaseController
  include WebsocketRails::Logging
  def new_message
    @message = ChatMessage.new message_params(message)
    current_user.reload if current_user
    if current_user and current_user.can_create?(@message)
      if @message.save
        trigger_success
      else
        trigger_failure(errors: @message.errors.full_messages.uniq)
      end
    else 
      trigger_failure
    end
  end

  def client_connected
    if current_user
      current_user.reload
      current_user.update_online
    end
  end

  private 
    def message_params(params)
      info "Params"
      {content: params['content'], chat_id: params["chat_id"], user: current_user}
    end
end