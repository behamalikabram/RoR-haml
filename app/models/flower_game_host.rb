class FlowerGameHost < ActiveRecord::Base
  include StringifyAmountModel
  include FlowerGameHostChannels

  include Authority::Abilities
  self.authorizer_name = 'FlowerGameHostAuthorizer'

  has_one :chat, -> {where(flowers_chat: true)}, foreign_key: :host_id, dependent: :destroy

  BET_LIMITS = {"host_1" => {"min_bet" => 2000000, "max_bet" => 300000000}, "host_2" => {"min_bet" => 3000000, "max_bet" => 600000000}, "host_3" => {"min_bet" => 4000000, "max_bet" => 1000000000}, "admin" => {"min_bet" => 1000000, "max_bet" => 10000000000}, "moderator" => {"min_bet" => 4000000, "max_bet" => 1000000000}}

  belongs_to :host, class_name: "User"
  attr_accessor :string_min_bet, :string_max_bet

  validates_uniqueness_of :host
  validates_presence_of :host, :stream_link

  validate :correct_string_bet

  default_scope -> {includes(:host)}
  scope :online, -> {joins(:host).where(online: true)}

  after_create :create_chat

  def self.host_exists?(user)
    where(host: user).any?
  end

  def self.host_online?(user)
    where(host: user).online.any?
  end

  def go_online
    update_attribute(:online, true)
    trigger_event(:host_online)
  end

  def go_offline
    update_attribute(:online, false)
    trigger_event(:host_offline)
  end

  def to_s
    host.to_s
  end

  def min_bet_to_s
    stringify_amount(min_bet)
  end

  def max_bet_to_s
    stringify_amount(max_bet)
  end

  def bet_range
    "#{min_bet_to_s} - #{max_bet_to_s}"
  end

  private
    def correct_string_bet
      new_min_bet = validate_correct_string_amount(string_min_bet, :min_bet)
      new_max_bet = validate_correct_string_amount(string_max_bet, :max_bet)
      unless errors.any?
        self.min_bet = new_min_bet
        self.max_bet = new_max_bet
        errors.add(:maximum_bet, "can't be lower that minimum bet") if min_bet > max_bet
        validate_bet_limits 
      end
    end

    def validate_bet_limits
      limits = BET_LIMITS[host.role.name]
      errors.add(:max_bet, "is too high for your rank") if max_bet > limits["max_bet"]
      errors.add(:min_bet, "is too low for your rank") if min_bet < limits["min_bet"]
    end
end
