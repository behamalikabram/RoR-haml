class AddTypeToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :type, :string, default: '', nil: false
    remove_column :chat_messages, :admin_command, :boolean
  end
end
