class CreateDiceRolls < ActiveRecord::Migration
  def change
    create_table :dice_rolls do |t|
      t.belongs_to :dice_game, index: true
      t.belongs_to :user
      t.integer :roll
      t.boolean :winning_roll, default: false

      t.timestamps
    end
  end
end
