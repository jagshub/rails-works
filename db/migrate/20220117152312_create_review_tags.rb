class CreateReviewTags < ActiveRecord::Migration[6.1]
  def change
    create_table :review_tags do |t|
      t.string :body, null: false, index: { unique: true }

      t.timestamps null: false
    end
  end
end
