class AddBetRankToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bet_rank, :integer, default: 0
  end
end
