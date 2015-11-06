class AddFlowersChatToChats < ActiveRecord::Migration
  def change
    add_column :chats, :flowers_chat, :boolean, default: false
  end
end
