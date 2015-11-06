class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.belongs_to :user
      t.text :content

      t.timestamps
    end
  end
end
