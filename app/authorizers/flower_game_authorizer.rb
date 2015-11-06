class FlowerGameAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
    # FlowerGameHost.host_online?(user)
  end

  def updatable_by?(user)
    resource.host == user and resource.accepted?
  end

  def readable_by?(user)
    true
    #user == resource.host or user == resource.bettor
  end

  def acceptable_by?(user)
    resource.new? and resource.has_user?(user) and resource.creator != user
  end

  def cancellable_by?(user)
    (resource.bettor == user or resource.host == user) and resource.new?
  end
end
