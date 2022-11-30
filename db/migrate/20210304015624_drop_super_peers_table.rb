class DropSuperPeersTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :super_peers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
