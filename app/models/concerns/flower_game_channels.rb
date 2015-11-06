module FlowerGameChannels
  include WebsocketChannels

  EVENT_CALLBACKS = {game_completed: :create_flower_message}

  def to_json
    { id: id, pot: pot_to_s, bet: bet_to_s, host: host.to_s, 
      bettor: bettor.to_s, user_won: user_won?, color: color, 
      invited_user: invited_user.to_s }
  end

  def to_users_json
    {id: id, bettor: bettor.to_s, host: host.to_s, invited_user: invited_user.to_s}
  end

  def game_channel
    WebsocketRails["flower_game_#{id}"]
  end

  def games_channel
    WebsocketRails["flower_games"]
  end

  def all_channels
    [game_channel, games_channel]
  end

  def create_flower_message
    color_text = if color == "Rainbow"
      "<font color='#FF0000'>R</font><font color='#FFDB00'>a</font><font color='#FFff00'>i</font><font color='#24ff00'>n</font><font color='#00ff00'>b</font><font color='#00ffDB'>o</font><font color='#00ffff'>w</font> flower"
    else
      "<span class='#{color.downcase}'>#{color} flower</span>"
    end
    a = ChatMessage.create!(content: "has planted a #{color_text} for a <span class='money'>#{bet_to_s} bet</span>",
                            user: host, type: "dice_game_winner")
  end
end