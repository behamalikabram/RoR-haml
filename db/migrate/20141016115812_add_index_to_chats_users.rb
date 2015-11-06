class AddIndexToChatsUsers < ActiveRecord::Migration
  def change
    add_index :chats_users, [:user_id, :chat_id]
  end
end
