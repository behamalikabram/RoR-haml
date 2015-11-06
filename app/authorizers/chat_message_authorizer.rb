class ChatMessageAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    (!resource.chat or resource.chat.has_user?(user))
  end
end