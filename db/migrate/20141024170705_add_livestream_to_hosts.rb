class AddLivestreamToHosts < ActiveRecord::Migration
  def change
    add_column :flower_game_hosts, :stream_link, :string
    remove_column :flower_games, :user_color, :string
    add_column :flower_games, :user_confirmed, :boolean, default: false
  end
end
