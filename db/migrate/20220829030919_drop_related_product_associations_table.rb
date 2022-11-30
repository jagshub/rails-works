class DropRelatedProductAssociationsTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :related_product_associations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
