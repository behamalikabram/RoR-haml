class MoveBelongsToChatToTickets < ActiveRecord::Migration
  def change
    remove_column :chats, :ticket_id, :integer
    add_column :tickets, :chat_id, :integer
  end
end
