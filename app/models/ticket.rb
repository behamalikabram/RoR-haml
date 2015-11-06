class Ticket < ActiveRecord::Base 
  self.inheritance_column = nil
  
  include Authority::Abilities
  self.authorizer_name = 'TicketAuthorizer'
  include StringifyAmountModel

  ALLOWED_TYPES = ["deposit", "withdraw", "transfer"]
  ALLOWED_CURRENCIES = ["RS3", "07"]
  MINIMUM_DEPOSIT = 5000000
  MINIMUM_07_DEPOSIT = 1000000
  WITHDRAW_DELAY = 2.hours

  belongs_to :user
  delegate :wallet, to: :user
  belongs_to :chat, dependent: :destroy
  belongs_to :recipient_user, class_name: "User"

  attr_accessor :recipient_user_username, :string_amount, :accepted_by

  validates :currency, presence: true, inclusion: {in: ALLOWED_CURRENCIES}, 
                       if: :currency_required?

  validates_inclusion_of    :type,           in: ALLOWED_TYPES
  validates_presence_of     :recipient_user, if: :recipient_required?, message: "was not found"

  validate :correct_string_amount, :correct_recipient, :validate_recent_withdrawals, 
            on: :create

  before_validation :find_recipient_user
  after_create :complete, if: :transfer_type?
  after_create :reserve_amount, :trigger_websocket_event

  default_scope -> {order("created_at DESC")}

  scope :completed,     -> {where(state: :completed)}
  scope :not_completed, -> {where(state: :new)}
  scope :not_cancelled, -> {where.not(state: :cancelled)}
  scope :withdrawals,   -> {where type: :withdraw}

  scope :recent_withdrawals, -> { 
    withdrawals.not_cancelled.where("created_at > ?", Time.now - WITHDRAW_DELAY) 
  }


  state_machine initial: :new do
    after_transition :new => :completed, do: :complete_transaction
    after_transition :new => [:completed, :cancelled], do: :close_chat
    after_transition :new => :cancelled, do: :return_amount

    event :complete do
      transition :new => :completed
    end

    event :cancel do 
      transition :new => :cancelled
    end
  end

  # Transfer transactions doesn't use currency
  def currency_required? 
    deposit_type?
  end

  # Transfer happens from one user to another
  def recipient_required?
    transfer_type?
  end

  def to_s 
    amount_text = "#{stringify_amount(amount)} GP"
    case type
    when 'transfer'
      "transfer #{amount_text} to #{recipient_user}"
    else 
      curr = currency.blank? ? "" : "(#{currency})"
      "#{type} #{amount_text}" << curr
    end
  end

  def string_amount
    @string_amount || amount.to_s
  end

  def report 
    unless reported?
      User.admins.each do |a|
        TicketMailer.report_mail(self, a.email).deliver
      end
      update_attribute(:reported, true)
    end
  end

  private 
    def find_recipient_user
      self.recipient_user = User.where("lower(username) = ?", recipient_user_username.downcase).first if recipient_user_username
    end

    def correct_string_amount
      new_amount = validate_correct_string_amount(string_amount, :amount)
      unless errors.any?
        self.amount = new_amount
        case type
        when 'withdraw', 'transfer'
          errors.add(:amount, "is invalid. You don't have enough GP in your wallet") if amount > wallet.value
        when 'deposit'
          min = (currency == '07') ? MINIMUM_07_DEPOSIT : MINIMUM_DEPOSIT
          errors.add(:amount, "is incorrect. Minimum amount for deposit with #{currency} is #{min}.") if amount < min
        end 
      end
    end

    def correct_recipient
      errors.add(:recpieint_user, "is invalid. You can't trasfer funds to yourself") if recipient_user == user
    end

    def validate_recent_withdrawals
      if withdraw_type? and user.tickets.recent_withdrawals.any?
        errors.add(:you, "can submit only one withdraw request within 2 hours")
      end
    end

    def complete_transaction
      case type 
      when "transfer"
        wallet.remove(amount)
        recipient_user.wallet.add(amount)
      when "deposit" 
        if accepted_by
          accepted_by.wallet.remove(amount)
        end
        wallet.add(amount)
      when "withdraw"
        if accepted_by
          accepted_by.wallet.add(amount)
        end
        # wallet.remove(amount)
      end
    end

    def reserve_amount
      wallet.remove(amount) if withdraw_type?
    end

    def return_amount
      wallet.add(amount) if withdraw_type?
    end

    def close_chat
      chat.close if chat
    end

    def method_missing(meth, *args, &block)
      # Defines new methods such as Ticket#deposit_type?, Ticket#transfer_type?
      if meth =~ /^(.+)_type\?$/ and ALLOWED_TYPES.include?($1)
        type == $1
      else
        super
      end
    end

    def trigger_websocket_event
      WebsocketRails[:tickets].trigger(:update_count, {count: Ticket.not_completed.count}) unless transfer_type?
    end
end
