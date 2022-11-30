class CreateProductTopicAssociations < ActiveRecord::Migration[6.1]
  def change
    create_table :product_topic_associations do |t|
      t.references :product, null: false, foreign_key: true, index: true
      t.references :topic, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :product_topic_associations, [:product_id, :topic_id], unique: true
  end
end
