class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.belongs_to :user
      t.integer    :value, default: 0

      t.timestamps
    end

    add_index :wallets, :user_id, unique: true
  end
end
