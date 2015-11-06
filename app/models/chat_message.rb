class ChatMessage < ActiveRecord::Base
  self.inheritance_column = nil

  include Authority::Abilities
  self.authorizer_name = 'ChatMessageAuthorizer'

  COMMANDS = %W{banip unbanip banc unbanc mute unmute ban unban winner}
  REGEX = /\A\/(#{COMMANDS.join("|")})\s?([\S]*?)?(\s\d*)?\z/
  COMMANDS_MESSAGES = {"banc" => "was banned from using chat", "unbanc" => "was unbanned in chat",  
                       "mute" => "was muted", "unmute" => "was unmuted", 
                       "ban" => "was banned on duelallday.com", 
                       "unban" => "was unbanned on duelallay.com", "banip" => "was banned by IP address", 
                       "unbanip" => "was unbanned by IP address"}

  SPAM_PREVENTION_TIME = 3.seconds
  SPAM_PREVENTION_MESSAGES_COUNT = 2

  belongs_to :chat
  belongs_to :user
  delegate :chat_role, :role, to: :user

  before_validation :squish_content

  validates_presence_of :content
  validates_length_of :content, in: 2..100, if: :type_blank?
  validate :user_banned, :spam_prevention, on: :create
  validate :admin_commands, :chat_opened

  default_scope -> {includes(:user => :role)}
  scope :no_chat, -> {where(chat_id: nil)}
  scope :recent, -> {where("created_at > ?", SPAM_PREVENTION_TIME.ago)}

  # attr_accessor :admin_command

  after_create :trigger_chat_update

  def to_s
    !type.blank? ? content.html_safe : content
  end

  private 

    def method_missing(meth, *args, &block)
      if meth =~ /\A(.+)_type\?\z/
        type.to_s == $1
      else
        super
      end
    end

    def trigger_chat_update
      channel = if chat
        chat.channel_name
      else 
        :general_chat
      end

      WebsocketRails[channel].trigger(:update_chat, {message: content, 
                                                       from: user.to_s, 
                                                       role: user.chat_role,
                                                       type: type, 
                                                       created_at: created_at})
      user.update_online unless type
    end

    def squish_content
      content.squish!
    end

    def chat_opened
      if chat and !chat.opened?
        errors.add(:chat, "#{chat_id} was closed by host")
      end
    end

    def type_blank?
      type.blank?
    end

    def user_banned
      errors.add(:you, "are muted in this chat #{user.mute_duration}") if (!user.can_access_chatbox? and !chat)
    end

    def admin_commands
      if content =~ REGEX
        command, username, duration = $1, $2, $3

        return unless user.can_execute_admin_command?(command)

        if command == "winner"
          logger.info WebsocketRails.users.users.keys.inspect
          users_ids = WebsocketRails.users.users.keys
          users = User.normal_users.where(id: users_ids)
          winner_id = users.sample 
          if users.count > 1
            u = users.order("RANDOM()").first
            text = "Congratulations #{u} you won the giveaway!"
            assign_attributes(content: text, type: "admin_command")
          else 
            errors.add(:not_enough, "users for /winner command")
          end
          return
        end

        duration = nil if command != "mute"
        # No nickname
        return errors.add(:you, "didn't specify the username") if username.blank?

        target_user = User.find_by_username(username)

        # User with this username was not found
        return errors.add(:user, "with '#{username}' username was not found") unless target_user

        if target_user.is_admin? or target_user.role == user.role or (!(user.is_admin? or user.is_moderator?) and (!target_user.is_user? ))
          return errors.add(:you, "can't #{command} this user") 
        end

        # No duration provided for mute command
        return errors.add(:mute, "command requires mute duration in seconds entered after the username") if command == "mute" and duration.blank?

        target_user.execute_admin_command(command, duration)

        text = COMMANDS_MESSAGES[command]
        duration = (duration.blank? ? "" : "for #{duration.to_i} seconds")

        assign_attributes(content: "#{username} #{text} #{duration}", type: "admin_command")
      end
    end

    def spam_prevention
      if (user.is_user? or user.is_trader?) and type.blank? and user.chat_messages.recent.count >= SPAM_PREVENTION_MESSAGES_COUNT 
        user.execute_admin_command("mute", 20)
      end
    end
end
