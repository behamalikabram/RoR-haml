class CreateDiceGamesUsers < ActiveRecord::Migration
  def change
    create_table :dice_games_users do |t|
      t.belongs_to :user
      t.belongs_to :dice_game 
      t.boolean :winner, default: false

      t.timestamps
    end
    
    add_index :dice_games_users, [:user_id, :dice_game_id]
  end
end
