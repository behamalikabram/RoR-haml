class ChangeColumnTypesToBigint < ActiveRecord::Migration
  def up 
    change_column :wallets,    :value,  :bigint
    change_column :dice_games, :bet,    :bigint
    change_column :tickets,    :amount, :bigint
  end

  def down
    change_column :wallets,    :value,  :integer
    change_column :dice_games, :bet,    :integer
    change_column :tickets,    :amount, :integer
  end
end
