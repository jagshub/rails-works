class RemoveJobProductAssociation < ActiveRecord::Migration[5.2]
  def change
    drop_table :job_product_associations
  end
end
