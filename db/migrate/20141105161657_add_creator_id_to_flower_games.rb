class AddCreatorIdToFlowerGames < ActiveRecord::Migration
  def change
    add_column :flower_games, :creator_id, :integer
  end
end
