WebsocketRails::EventMap.describe do
  # private_channel :tickets

  namespace :websocket_rails do
    subscribe :subscribe_private, :to => WebsocketsAuthorizationController, :with_method => :authorize_channels
  end
  
  namespace :chat do
    subscribe :new_message, to: WebsocketsChatController, with_method: :new_message
  end

  # The :client_connected method is fired automatically when a new client connects
  subscribe :client_connected, :to => WebsocketsChatController, :with_method => :client_connected
end