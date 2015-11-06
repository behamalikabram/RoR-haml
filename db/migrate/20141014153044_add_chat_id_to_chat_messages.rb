class AddChatIdToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :chat_id, :integer, index: true
  end
end
