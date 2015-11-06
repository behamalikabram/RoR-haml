class CreateFlowerGames < ActiveRecord::Migration
  def change
    create_table :flower_games do |t|
      t.string :color
      t.string :user_color
      t.belongs_to :host
      t.belongs_to :bettor
      t.boolean :user_won, default: false
      t.string :state
      t.integer :bet, limit: 5
      t.integer :pot, limit: 5

      t.timestamps
    end
  end
end
