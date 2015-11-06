class AddLastOnlineAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_online_at, :datetime
  end
end
