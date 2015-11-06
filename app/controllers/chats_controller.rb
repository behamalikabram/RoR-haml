class ChatsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_chat, only: [:show]
  before_action :set_new_chat, only: [:create]
  before_action :no_new_notifications
  # authorize_actions_for Chat, only: [:create]

  def show
    # Do not user @chat.messages.build or new
    @message = ChatMessage.new(chat: @chat)
  end

  def create
    if @chat.save 
      @ticket.update_attributes(:chat_id => @chat.id)
      WebsocketRails.users[@chat.users.first.id].send_message('new_notification')
      redirect_to @chat, notice: "Chat created"
    else 
      redirect_to tickets_path, notice: "Unable to open a chat"
    end
  end

  def index
    @chats = current_user.chats.new_with_ticket.includes(:ticket, :host)
  end

  private 
    def set_chat
      @chat = Chat.find(params[:id])
      authorize_action_for @chat 
    end

    def set_new_chat
      @chat = Chat.new(chat_params)
      # Avoid @ticket.chat_id being nil(because of new chat)
      @ticket.reload
      authorize_action_for @chat
    end

    def chat_params
      @ticket = Ticket.find(params[:ticket_id])
      {ticket: @ticket, host: current_user, user_ids: [@ticket.user_id]}
    end

    def no_new_notifications
      @any_new_notifications = false
    end

    def authority_forbidden(error)
      redirect_to tickets_path, alert: "You can't use this chat"
    end
end
