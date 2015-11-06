module FlowerGameHostChannels
  include WebsocketChannels

  # EVENT_CALLBACKS = {game_completed: :create_flower_message}

  def to_json
    { id: id, name: to_s, bet_range: bet_range, chat: chat.channel_name}
  end

  def games_channel
    WebsocketRails["flower_games"]
  end

  def all_channels
    [games_channel]
  end

  # def create_flower_message
  #   a = ChatMessage.create!(content: "has planted a #{color} flower for a <span class='money'>#{bet_to_s} bet</span>",
  #                           user: host, type: "dice_game_winner")
  # end
end