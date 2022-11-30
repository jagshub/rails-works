class CreateReviewTagAssociations < ActiveRecord::Migration[6.1]
  def change
    create_table :review_tag_associations do |t|
      t.references :review, foreign_key: true, null: false
      t.references :review_tag, foreign_key: true, null: false

      # Note(AR): Positive or negative
      t.integer :sentiment, null: false

      t.timestamps null: false

      t.index [:review_id, :review_tag_id, :sentiment], unique: true, name: 'index_review_tag_associations_on_join'
    end
  end
end
