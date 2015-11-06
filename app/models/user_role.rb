class UserRole < ActiveRecord::Base
  # If add a new role to db, also add it into corresponding migration
  has_many :users 

  def to_s 
    # Some ranks can be defined as 'trader_1', 'trader_2', etc. Use UserRole#name to get the actual rank
    name.split("_").first
  end
end
