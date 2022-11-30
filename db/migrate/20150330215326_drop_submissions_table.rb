class DropSubmissionsTable < ActiveRecord::Migration
  def up
    drop_table :submissions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
