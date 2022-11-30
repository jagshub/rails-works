class CreatePostDrafts < ActiveRecord::Migration[5.1]
  def change
    create_table :post_drafts do |t|
      t.references :post, foreign_key: true, null: false, index: { unique: true }
      t.references :user, foreign_key: true, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :post_drafts, %i(post_id status)
  end
end
