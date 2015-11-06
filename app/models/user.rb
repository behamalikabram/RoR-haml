class User < ActiveRecord::Base
  include Authority::UserAbilities
  include Authority::Abilities
  include StringifyAmount

  self.authorizer_name = 'UserAuthorizer'
  
  DEFAULT_ROLE = :user 
  BAN_COMMANDS_ATTRIBUTES = {"banc" => "chatbox_banned", "mute" => "muted", "ban" => "banned", "banip" => "ip_banned"}
  MODERATOR_COMMANDS = %W{banc unbanc mute unmute winner}
  TRADER_COMMANDS = %W{mute unmute}

  # Ticket limits
  TRADERS_GP_LIMITS = {"trader_1" => "100m", "trader_2" => "250m", "trader_3" => "500m"}
  BET_RANKS_MAP = {1 => '50m', 2 => '100m', 3 => '150m', 4 => "250m", 5 => "375m", 
                   6 => "675m", 7 => "975m", 8 => "1.2b", 9 => "2b"}
  STRING_BET_RANKS_MAP = BET_RANKS_MAP.dup
  numerify_string_values!(TRADERS_GP_LIMITS, BET_RANKS_MAP)

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  belongs_to :role, class_name: "UserRole"
  attr_accessor :role_name, :login

  has_one :wallet, dependent: :destroy
  has_one :flower_game_host, foreign_key: :host_id
  has_many :tickets, dependent: :destroy
  has_many :tickets_as_recipient, class_name: "Ticket", foreign_key: "recipient_user_id"
  has_many :hosted_chats, class_name: "Chat", foreign_key: "host_id"
  has_many :chat_messages, dependent: :delete_all
  has_many :won_dice_games, class_name: "DiceGame", foreign_key: "winner_id"

  has_many :week_won_dice_games, -> {where("dice_games.created_at > ?", Time.now.at_beginning_of_week)}, class_name: "DiceGame", foreign_key: "winner_id"

  has_many :week_won_flower_games, -> {where("flower_games.created_at > ?", Time.now.at_beginning_of_week).where(user_won: true)},  class_name: "FlowerGame", foreign_key: "bettor_id"

  has_and_belongs_to_many :dice_games 
  has_and_belongs_to_many :chats

  has_and_belongs_to_many :completed_dice_games, -> {where("dice_games.state = ?", :completed)}, class_name: "DiceGame", join_table: "dice_games_users"
  has_many :completed_flower_games, -> {where("flower_games.state = ?", :completed)}, class_name: "FlowerGame", foreign_key: "bettor_id"

  validates :username, presence: true, uniqueness: {:case_sensitive => false}, length: {in: 3..16}
  validates_format_of :username, :with => /\A[A-Za-z\d_\-\s]+\z/, :message => "can only be alphanumeric"

  scope :normal_users, -> {where(role_id: UserRole.find_by_name(:user).id)}
  scope :admins, -> {where(role_id: UserRole.find_by_name(:admin).id)}
  scope :ip_banned, -> {where(ip_banned: true).where.not(ip: nil)}
  scope :week_deposit_tickets, -> {joins(:tickets).where("tickets.type" => :deposit, "tickets.state" => :completed).where("tickets.created_at > ?", Time.now.at_beginning_of_week)}
  scope :online, -> {where("last_online_at > ?", 5.minutes.ago)}

  
  def add_role(role_name)
    new_role = UserRole.find_by_name(role_name)
    raise ActiveRecord::RecordNotFound.new("Role with name '#{role_name}' was not found. Perhaps you misspelled it?") unless new_role
    if new_record? 
      self.role = new_role 
    else 
      self.update_attribute(:role, new_role)
    end
  end

  def to_s
    username
  end

  # For rails admin
  alias_method :name, :to_s

  def can_access_chatbox?
    !banned and !chatbox_banned and !ip_banned? and !still_muted?
  end

  def still_muted?
    muted and Time.now < muted_until
  end

  def mute_duration
    if banned or chatbox_banned or ip_banned?
      "forever"
    elsif still_muted?
      "for #{(muted_until - Time.now).round} seconds"
    end
  end

  def ip_banned?
    ip_banned or User.ip_banned.where(ip: ip).any?
  end

  def any_new_notifications?
    chats.new_with_ticket.any?
  end

  def execute_admin_command(command, duration=nil)
    # Check for reversed command(e.g unmute)
    is_reversed_command = (command =~ /^un(.*)/)
    direct_command = ($1 || command)

    # Find relevant attribute
    attribute = BAN_COMMANDS_ATTRIBUTES[direct_command]

    raise NoMethodError.new("No such command - #{command}") unless attribute
    if direct_command == 'banip'
      User.where(ip: ip).update_all(attribute => !is_reversed_command)
      return true
    end
    update_attrs = {attribute => !is_reversed_command}
    logger.info duration
    update_attrs["muted_until"] = Time.now + duration.to_i if (command == "mute")

    update_attributes(update_attrs)
  end

  def can_execute_admin_command?(command)
    case role.to_s 
    when "admin"
      true
    when "moderator", "host"
      MODERATOR_COMMANDS.include?(command)
    when "trader"
      TRADER_COMMANDS.include?(command)
    end
  end

  def chat_role
    r = role.to_s
    return "#{r}-#{bet_rank}" if is_user? and bet_rank > 0
    r
  end

  def flower_game_host_online?
    flower_game_host and flower_game_host.online?
  end

  def update_online
    if !last_online_at or last_online_at < 5.minutes.ago
      update_attribute(:last_online_at, Time.now)
      WebsocketRails['general_chat'].trigger(:user_online, {id: id, user: to_s, role: role.to_s})
    end
  end

  def self.deposit_leaders
    limit(10).group(:username).order('sum_tickets_amount desc').sum("tickets.amount")
  end

  def self.dice_games_leaders
    joins(:week_won_dice_games).limit(10).group(:username).order('sum_dice_games_pot_dice_games_bet desc').sum("dice_games.pot - dice_games.bet")
  end

  def self.flower_games_leaders
    joins(:week_won_flower_games).limit(10).group(:username).order('sum_flower_games_pot_flower_games_bet desc').sum("flower_games.pot - flower_games.bet")
  end

  def self.week_winners
    d = dice_games_leaders
    f = flower_games_leaders
    d.merge(f) {|k, oldval, newval| oldval.to_i+newval.to_i}.sort_by {|k, v| -v}.first(10)
  end

  def self.update_ranks
    BET_RANKS_MAP.each do |rank, limit|
      ["flower_games", "dice_games"].each do |t|
        normal_users.joins("completed_#{t}".to_sym)
                    .where("#{t}.bet >= ?", limit)
                    .where("users.bet_rank < ?", rank)
                    .uniq.update_all(bet_rank: rank)
      end
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  before_create :add_default_role
  after_create :create_wallet

  private
    def add_default_role
      add_role(self.role_name || DEFAULT_ROLE) unless role  
    end

    def method_missing(meth, *args, &block)
      # Defines new methods such as User#is_user?, User#is_admin?
      if meth.to_s =~ /^is_(.+)\?$/
        role.to_s == $1
      else
        super
      end
    end
end
