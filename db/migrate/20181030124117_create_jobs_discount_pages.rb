class CreateJobsDiscountPages < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs_discount_pages do |t|
      t.string :name, null: false
      t.text :text, null: false
      t.string :slug, index: { unique: true }
      t.integer :discount_value, null: false, default: 0
      t.string :discount_plan_ids, null: false, array: true, default: []
      t.integer :jobs_count, null: false, default: 0
      t.datetime :trashed_at
      t.timestamps null: false
    end
  end
end
