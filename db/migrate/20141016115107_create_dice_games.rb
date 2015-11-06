class CreateDiceGames < ActiveRecord::Migration
  def change
    create_table :dice_games do |t|
      t.string :type
      t.integer :capacity
      t.integer :bet
      t.string :state
      t.belongs_to :chat
      t.belongs_to :winner

      t.timestamps
    end
  end
end
