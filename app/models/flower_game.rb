class FlowerGame < ActiveRecord::Base
  include StringifyAmountModel
  include FlowerGameChannels
  include Rails.application.routes.url_helpers

  include Authority::Abilities
  self.authorizer_name = 'FlowerGameAuthorizer'

  COLORS = %W{Red Orange Yellow Blue Purple Pastel Rainbow White Black}
  WINNING_COLORS = %W{Blue Purple Pastel}

  belongs_to :bettor, class_name: "User"
  belongs_to :host, class_name: "User"
  belongs_to :creator, class_name: "User"
  belongs_to :flower_game_host, foreign_key: :host_id, primary_key: :host_id 
  delegate :chat, to: :flower_game_host
  attr_accessor :string_bet, :bettor_username, :host_username

  # Also validates correct username(bettor or host)
  validate :correct_string_bet,  on: :create

  validates :color, inclusion: {in: COLORS}, allow_blank: true
  validates_presence_of :creator

  default_scope -> {order("flower_games.created_at DESC").includes(:bettor, :host)}
  scope :current,   -> {where state: :new}
  scope :completed, -> {where state: :completed}
  scope :cancelled, -> {where state: :cancelled}

  before_create :calculate_pot
  after_create :send_message

  state_machine initial: :new do
    after_transition :new => :accepted, do: :remove_pot_from_users
    after_transition :new => :accepted do |game, event|
      game.trigger_event(:game_accepted, game.game_channel, game.to_users_json)
    end

    before_transition :accepted => :completed, do: :check_winner
    after_transition  :accepted => :completed, do: :transfer_pot
      
    after_transition  :accepted => :completed do |game, event|
      game.trigger_event(:game_completed)
    end

    after_transition :new => :cancelled do |game, event|
      game.trigger_event(:game_cancelled, game.game_channel, game.to_users_json)
    end

    event :accept do 
      transition :new => :accepted
    end

    event :complete do
      transition :accepted => :completed
    end

    event :cancel do 
      transition :new => :cancelled
    end
  end

  def pot_to_s
    stringify_amount(pot)
  end

  def bet_to_s 
    stringify_amount(bet)
  end

  def has_user?(user)
    host == user or bettor == user
  end

  def invited_user
    if host == creator 
      bettor 
    elsif bettor == creator
      host
    end
  end

  private
    def correct_string_bet
      correct_users
      new_bet = validate_correct_string_amount(string_bet, :bet)
      unless errors.any?
        self.bet = new_bet
        errors.add(:host, "don't have enough GP in their wallet") if host.wallet.value < bet
        errors.add(:bettor, "don't have enough GP in their wallet") if bettor.wallet.value < bet
      end
    end

    def correct_users
      users = []
      return errors.add(:no, "host user or bettor user specified") if (!host and !bettor)

      u = if !host
        :host 
      else
        :bettor 
      end

      username_attr = "#{u}_username"
      username = send(username_attr)

      return errors.add(username_attr, "can't be blank") if username.blank?
      user = User.find_by_username(username)

      if u == :host and user and !FlowerGameHost.host_online?(user) 
        user = nil
      end
      return errors.add(u, "was not found") unless user

      send("#{u}=", user)

      errors.add(:host, "and bettor can't be the same user") if host == bettor
    end

    def total_pot 
      bet*2
    end

    def remove_pot_from_users
      host.wallet.remove(bet)
      bettor.wallet.remove(bet)
    end

    def calculate_pot
      self.pot = total_pot
    end

    def transfer_pot
      if user_won?
        bettor.wallet.add(pot)
      else
        host.wallet.add(pot)
      end
    end

    def return_pot
      bettor.wallet.add(bet)
    end

    def check_winner
      self.user_won = (WINNING_COLORS.include?(color))
      true
    end

    def send_message
      content = if creator == host
        "invited #{bettor} to play a flower game! <a href=#{flower_game_path(self)}> Click here to view</a>"
      elsif creator == bettor 
        "wants to bet #{bet_to_s}! <a href=#{flower_game_path(self)}> Click here to view</a>"
      end
      chat.messages.create(user: creator, content: content, type: "admin_command")
    end
end
