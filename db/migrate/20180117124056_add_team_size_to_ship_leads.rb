class AddTeamSizeToShipLeads < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_leads, :team_size, :integer, default: 0, null: true

    execute <<-SQL
      UPDATE ship_leads SET team_size = 0
    SQL

    change_column_null :ship_leads, :team_size, false
  end
end
