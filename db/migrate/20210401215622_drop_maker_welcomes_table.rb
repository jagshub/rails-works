class DropMakerWelcomesTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :maker_welcomes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
