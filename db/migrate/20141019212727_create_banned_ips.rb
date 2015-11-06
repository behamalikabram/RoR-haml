class CreateBannedIps < ActiveRecord::Migration
  def change
    add_column :users, :ip, :string, index: true
    add_column :users, :ip_banned, :boolean, default: false
  end
end
