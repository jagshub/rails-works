class CreatePostTagAssociations < ActiveRecord::Migration
  def change
    create_table :post_tag_associations do |t|
      t.references :post, index: true, foreign_key: true
      t.references :tag, index: true, foreign_key: true
      t.text :source_type
      t.integer :source_id

      t.timestamps null: false
    end
  end
end
