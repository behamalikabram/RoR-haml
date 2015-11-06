class DiceGameAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
    # !user.is_admin?
  end

  def readable_by?(user)
    true
  end

  def joinable_by?(user)
    resource.new? and !resource.full? and !resource.users.include?(user) and user.wallet.value >= resource.bet
  end

  def leaveable_by?(user)
    resource.new? and !resource.full? and resource.users.include?(user)
  end

  def rollable_by?(user)
    resource.new? and resource.full? and resource.users_without_roll.include?(user)
  end
end