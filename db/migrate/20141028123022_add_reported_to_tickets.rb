class AddReportedToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :reported, :boolean, default: false
  end
end
