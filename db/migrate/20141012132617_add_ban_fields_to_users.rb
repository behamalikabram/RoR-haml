class AddBanFieldsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t| 
      t.boolean :muted, default: false
      t.datetime :muted_until
      t.boolean :banned, default: false
      t.boolean :chatbox_banned, default: false
    end
  end
end
