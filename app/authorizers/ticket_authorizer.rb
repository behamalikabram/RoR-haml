class TicketAuthorizer < ApplicationAuthorizer
  LIMITS = User::TRADERS_GP_LIMITS

  def self.readable_by?(user)
    !user.is_user?
  end

  def creatable_by?(user)
    true
    # !user.is_admin?
  end

  def reportable_by?(user)
    resource.user == user and !resource.reported?
  end

  # def updatable_by?(user)
  #   chat = resource.chat
  #   !user.is_user? and (!chat or chat.has_user?(user))
  # end

  def acceptable_by?(user)
    return false if !resource.new? or user.is_user? or 
                    ((chat = resource.chat) and !chat.has_user?(user))
    amount = resource.amount
    if limit = LIMITS[user.role.name]
      amount <= limit and (!resource.deposit_type? or user.wallet.has_amount?(amount))
    else 
      (!resource.deposit_type? or user.wallet.has_amount?(amount))
    end
  end

  def cancellable_by?(user)
    resource.new? and (resource.user == user or !user.is_user?)
  end
end