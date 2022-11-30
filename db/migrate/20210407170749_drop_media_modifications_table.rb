class DropMediaModificationsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :media_modifications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
