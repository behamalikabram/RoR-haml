class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.belongs_to :host
      t.belongs_to :ticket
      t.string :state

      t.timestamps
    end

    add_index :chats, :ticket_id, unique: true
  end
end
