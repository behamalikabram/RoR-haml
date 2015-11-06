class CreateFlowerGameHosts < ActiveRecord::Migration
  def change
    create_table :flower_game_hosts do |t|
      t.belongs_to :host, index: true, unique: true
      t.integer :min_bet, limit: 5
      t.integer :max_bet, limit: 5
      t.boolean :online, default: false

      t.timestamps
    end
  end
end
