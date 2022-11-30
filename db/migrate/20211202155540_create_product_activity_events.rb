class CreateProductActivityEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :product_activity_events do |t|
      t.references :product, foreign_key: true, null: false, index: false
      t.references :subject, polymorphic: true, null: false
      t.timestamp :occurred_at, null: false

      t.index [:product_id, :subject_type, :subject_id], unique: true, name: 'index_product_activities_unique'

      t.timestamps null: false
    end
  end
end
