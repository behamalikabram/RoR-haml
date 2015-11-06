module DiceGameChannels
  include WebsocketRails::Logging
  include WebsocketChannels

  EVENT_CALLBACKS = {game_completed: :create_winner_message}

  def to_json
    { id: id, pot: pot_to_s, bet: bet_to_s, users: users_names, 
      capacity: users_capacity, user: @joining_user.to_s, full: full?, 
      winner: winner.to_s, type: type }
  end

  def to_stage_json
    {id: id, users: users_names(current_stage_users), stage: stage}
  end

  def game_channel
    info "game_channel_log #{id} --- #{WebsocketRails["dice_game_#{id}"].inspect}"
    WebsocketRails["dice_game_#{id}"]
  end

  def games_channel
    info "games_channel_log --- #{WebsocketRails["dice_games"].inspect}"
    WebsocketRails["dice_games"]
  end

  def all_channels
    [game_channel, games_channel]
  end

  def create_winner_message
    if duel_type?
      ChatMessage.create(content: "won <span class='money'>#{pot_to_s}</span> pot in #{id} duel room!", user: winner, 
                         type: "dice_game_winner")
    end
  end

end