class Chat < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'ChatAuthorizer'

  has_many :messages, class_name: "ChatMessage", dependent: :destroy
  has_and_belongs_to_many :users, dependent: :destroy
  belongs_to :host, class_name: "User"
  # belongs_to :ticket, dependent: :destroy
  has_one :ticket
  has_one :dice_game

  validates_presence_of :users, unless: :flowers_chat
  # validates_uniqueness_of :ticket_id, :dice_game_id, allow_blank: true

  # after_create :make_private_channel

  scope :opened, -> {where('chats.state' => :opened, 'chats.flowers_chat' => false)}
  scope :new_with_ticket, -> {joins(:ticket).opened}

  state_machine initial: :opened do
    after_transition :opened => :closed do |c, e|
      WebsocketRails[c.channel_name].trigger("closed")
    end
    event :close do
      transition :opened => :closed
    end
  end

  def channel_name
    if flowers_chat?
      "flowers_chat_#{id}"
    else 
      "user_chat_#{id}"
    end
  end

  def has_user?(user)
    return true if flowers_chat
    host == user or users.include?(user)
  end

  def users_list
    users.pluck(:username) << host.username
  end

  def make_private_channel
    WebsocketRails[channel_name].make_private unless flowers_chat?
  end
end
