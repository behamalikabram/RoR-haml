class DiceRoll < ActiveRecord::Base
  belongs_to :dice_game
  belongs_to :user

  delegate :game_channel, to: :dice_game

  default_scope -> {order("dice_rolls.created_at ASC")}

  validates_presence_of :roll, :user, :dice_game, :stage
  after_create :inform_channel

  def to_s
    s = "#{user} rolls #{roll}"
  end

  def to_json
    {text: to_s, user: user.to_s, winning: winning_roll?}
  end

  def make_winning_roll
    update_attribute(:winning_roll, true)
  end

  def inform_channel
    text = if dice_game.bank_type?
      t = "against the bank"
      t << (winning_roll? ? " and won!" : " and lost.")
      t 
    end
    dice_game.trigger_event(:roll, game_channel, to_json)
    ChatMessage.create(content: "rolled <span class='number'>#{roll}</span> for <span class='money'>#{dice_game.pot_to_s}</span> pot #{text}", user: user, type: "dice_roll")
  end
end
