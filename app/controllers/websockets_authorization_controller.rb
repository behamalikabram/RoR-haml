class WebsocketsAuthorizationController < WebsocketRails::BaseController
  def authorize_channels
    channel = WebsocketRails[message[:channel]].name
    if current_user and can_subscribe_to?(channel)
      accept_channel(username: current_user.username)
    else
      deny_channel
    end
  end

  private 
    def can_subscribe_to?(channel)
      case channel.to_s
      when "tickets"
        current_user.can_read?(Ticket)
      when /user_chat_(\d+)/
        @chat = Chat.find($1)
        current_user.can_read? @chat
      end
    end
end