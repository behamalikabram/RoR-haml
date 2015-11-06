class AddPotToDiceGames < ActiveRecord::Migration
  def change
    add_column :dice_games, :pot, :bigint
  end
end
