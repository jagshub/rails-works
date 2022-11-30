class CreateJobProductAssociations < ActiveRecord::Migration
  def change
    create_table :job_product_associations do |t|
      t.references :product, null: false
      t.references :job, null: false
      t.timestamps null: false
    end

    add_foreign_key :job_product_associations, :products, on_delete: :cascade
    add_foreign_key :job_product_associations, :jobs, on_delete: :cascade

    add_index :job_product_associations, [:product_id, :job_id], unique: true, name: 'index_job_product_associations_product_job'
  end
end
