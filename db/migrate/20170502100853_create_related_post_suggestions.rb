class CreateRelatedPostSuggestions < ActiveRecord::Migration
  def change
    create_table :related_post_suggestions do |t|
      t.references :post, index: true, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.timestamps null: false
    end

    add_reference :related_post_suggestions, :suggested_post, references: :posts, index: true
    add_foreign_key :related_post_suggestions, :posts, column: :suggested_post_id
  end
end
