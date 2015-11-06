class Wallet < ActiveRecord::Base
  include StringifyAmountModel
  attr_accessor :add_amount
  
  belongs_to :user

  after_save :add_amount_from_string, if: :add_amount
  
  def add(amount)
    self.update_attribute(:value, amount + value)
  end

  def remove(amount)
    self.update_attribute(:value, value - amount)
  end

  def has_amount?(amount)
    value >= amount
  end


  def value_to_s
    stringify_amount(value)
  end
  
  alias_method :to_s,  :value_to_s
  # For rails admin
  alias_method :title, :value_to_s

  private
    def add_amount_from_string
      a = add_amount
      self.add_amount = nil
      if amount = numerify_string(a)
        add(amount)
      end
    end
end
