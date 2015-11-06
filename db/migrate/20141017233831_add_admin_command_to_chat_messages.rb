class AddAdminCommandToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :admin_command, :boolean, default: false
  end
end
