class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.string :name

      t.timestamps
    end
    
    add_index :user_roles, :name, unique: true

    reversible do |direction|
      direction.up do
        puts "-- creating admin, moderator and user roles"
        ["admin", "user", "moderator", "trader_1", "trader_2", "trader_3", "host_1", "host_2", "host_3"].each {|r| UserRole.where(name: r).first_or_create }
        puts "-- done"
      end
    end
  end
end
