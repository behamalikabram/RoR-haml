class FlowerGameHostAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    (user.is_host? or user.is_admin? or user.is_moderator?) and !FlowerGameHost.host_exists?(user)
  end

  def updatable_by?(user)
    resource.host == user
  end
end
  