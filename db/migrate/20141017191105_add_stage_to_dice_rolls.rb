class AddStageToDiceRolls < ActiveRecord::Migration
  def change
    add_column :dice_rolls, :stage, :integer
  end
end
