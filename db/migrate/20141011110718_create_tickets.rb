class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.text :message
      t.integer :amount
      t.string :type
      t.string :state
      t.belongs_to :user
      t.string :currency
      t.belongs_to :recipient_user

      t.timestamps
    end

    add_index :tickets, :user_id
    add_index :tickets, :recipient_user_id
  end
end
