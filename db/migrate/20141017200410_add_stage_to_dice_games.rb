class AddStageToDiceGames < ActiveRecord::Migration
  def change
    add_column :dice_games, :stage, :integer, default: 1
  end
end
