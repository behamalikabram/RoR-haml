class ChatAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    resource.opened? and resource.has_user?(user)
  end

  def self.creatable_by?(user)
    !user.is_user?
  end

  def creatable_by?(user)
    !resource.ticket.chat_id and resource.ticket.acceptable_by?(user)
  end
end