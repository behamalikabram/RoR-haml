class DiceGame < ActiveRecord::Base
  self.inheritance_column = :nil

  include Authority::Abilities
  self.authorizer_name = 'DiceGameAuthorizer'

  include StringifyAmountModel
  include DiceGameChannels

  COMISSION = 5
  CAPACITY = 2..5
  TYPES = %W{duel 55x2}
  BETS_AMOUNTS = {"duel" => 1000000, "55x2" => 250000}

  has_and_belongs_to_many :users, dependent: :destroy
  belongs_to :winner, class_name: "User"
  has_many :rolls, class_name: "DiceRoll", dependent: :destroy

  attr_accessor :winning_user_id, :string_bet, :joining_user

  before_validation :set_capacity

  validates_inclusion_of :capacity, in: CAPACITY, presence: true, if: :duel_type?

  validates :type, inclusion: {in: TYPES}, presence: true
  validate :correct_string_bet, on: :create

  default_scope -> {order("dice_games.created_at DESC").includes(:users, :rolls, :winner)}

  scope :current, -> {where state: :new}
  scope :completed, -> {where state: :completed}
  scope :cancelled, -> {where state: :cancelled}
  scope :this_week, -> {where("dice_games.created_at > ?", Time.now.at_beginning_of_week)}
  scope :duels, -> {where type: :duel}
  scope :banks, -> {where type: "55x2"}

  after_destroy do |r|
    r.trigger_event(:game_cancelled)
  end

  after_create do |r|
    if r.duel_type? 
      r.delay(run_at: 2.minutes.from_now).cancel_if_not_full
    elsif r.bank_type?
      r.set_delay_on_roll
    end
  end

  before_create :calculate_pot

  state_machine initial: :new do
    after_transition  :new => :completed, do: [:transfer_bet]

    after_transition  :new => :completed do |game, event|
      game.trigger_event(:game_completed)
    end

    before_transition :new => :cancelled, do: :return_bet

    after_transition  :new => :cancelled do |game, event|
      game.trigger_event(:game_cancelled)
    end

    event :complete do
      transition :new => :completed
    end

    event :cancel do 
      transition :new => :cancelled
    end
  end

  def users_capacity
    "#{users.count}/#{capacity}"
  end

  def users_names(users=nil)
    users ||= self.users
    users.pluck(:username).join(", ")
  end

  def pot_to_s
    stringify_amount(pot)
  end

  def bet_to_s 
    stringify_amount(bet)
  end

  def full?
    capacity <= users.count
  end

  def empty?
    users.count == 0
  end

  def add_user!(user)
    @joining_user = user
    users << user
    reserve_bet_from(user)

    trigger_event(:user_joined)

    user
  end

  def remove_user!(user)
    @joining_user = user
    users.delete(user)
    return_bet_to user

    trigger_event(:user_left)

    user
  end

  def winning_roll
    rolls.where(winning_roll: true).first
  end

  def roll!(user, cheat=false)
    case type
    when 'duel'
      puts "#{roll_range(cheat)} --------"
      i = rand(roll_range(cheat))

      roll_attributes = {user: user, roll: i, stage: stage}
      roll = rolls.create!(roll_attributes)

      # All current stage users rolled their dices
      if users_without_roll.count == 0
        if maximum_current_stage_rolls.count > 1
          # Several winners for current stage
          next_stage
        else
          # No similar rolls, only one winner
          add_winner_and_complete
        end
      end

      return roll
    when '55x2'
      i = rand(1..100)
      roll_attributes = {user: user, roll: i, stage: stage}
      if i >= 55
        roll_attributes[:winning_roll] = true
        roll = rolls.create!(roll_attributes)
        add_winner_and_complete
      else
        roll = rolls.create!(roll_attributes)
        complete
      end
    end
  end

  def maximum_current_stage_rolls
    stage_rolls = stage_rolls(stage)
    maximum_roll = stage_rolls.maximum(:roll)
    stage_rolls.where(roll: maximum_roll)
  end

  def users_without_roll(stage=nil)
    stage ||= self.stage
    ids = stage_rolls(stage).pluck(:user_id)
    stage_users(stage).where.not(id: ids)
  end

  def stage_rolls(stage)
    rolls.where(stage: stage)
  end

  def current_stage_users
    stage_users(stage)
  end

  def stage_users(stage)
    prev_rolls = rolls.where(stage: stage-1)

    if prev_rolls.any?
      roll = prev_rolls.maximum(:roll)
      ids = prev_rolls.where(roll: roll).pluck(:user_id)
      users.where(id: ids)
    else 
      users
    end
  end

  def cancel_if_not_full
    cancel unless full?
  end

  def roll_for_missing_users(stage)
    u = users_without_roll(stage)
    if u.any?
      u.each {|u| roll!(u) }
    end
  end

  def set_delay_on_roll
    delay(run_at: 60.seconds.from_now).roll_for_missing_users(stage)
  end

  def duel_type?
    type == 'duel'
  end

  def bank_type?
    type == '55x2'
  end

  def self.total_week_commission
    new.stringify_amount(duels.this_week.completed.sum("bet*capacity - pot")/4)
  end

  private 
    def next_stage
      update_attribute(:stage, stage+1)
      set_delay_on_roll
      trigger_event(:next_stage, game_channel, to_stage_json)
    end

    def add_winner_and_complete
      roll = maximum_current_stage_rolls.first
      roll.make_winning_roll

      update_attributes({winner_id: roll.user_id})

      complete
    end

    # Validation
    def correct_string_bet
      new_bet = validate_correct_string_amount(string_bet, :bet)
      unless errors.any?
        self.bet = new_bet
        errors.add(:you, "don't have enough GP in your wallet") if joining_user.wallet.value < bet
        min_amount = BETS_AMOUNTS[type]
        errors.add(:bet, "is too small. Minimum amount you can put on bet is #{stringify_amount(min_amount)}") if min_amount > bet
      end
    end


    # Bet transfer
    def transfer_bet
      winner.wallet.add(pot) if winner
    end

    def reserve_bet_from(user)
      user.wallet.remove(bet)
    end

    def return_bet_to(user)
      user.wallet.add(bet)
    end

    def return_bet
      users.each {|u| return_bet_to u }
    end

    def set_capacity
      if bank_type?
        self.capacity = 1
      end
    end

    def calculate_pot
      self.pot = case type
      when 'duel'
        amount = bet*capacity
        (amount - (amount/100)*COMISSION).round
      when '55x2'
        bet*2
      end
    end

    def roll_range(cheat)
      return (2..12) unless cheat
      maximum_roll = stage_rolls(stage).maximum(:roll).to_i
      if maximum_roll > 6
        maximum_roll = (maximum_roll + 1) if maximum_roll < 12
        maximum_roll..12
      else 
        6..12
      end
    end

end
