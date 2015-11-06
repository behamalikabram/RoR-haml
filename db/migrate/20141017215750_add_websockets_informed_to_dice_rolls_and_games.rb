class AddWebsocketsInformedToDiceRollsAndGames < ActiveRecord::Migration
  def change
    add_column :dice_games, :websockets_informed, :boolean, default: false
    add_column :dice_rolls, :websockets_informed, :boolean, default: false
  end
end
