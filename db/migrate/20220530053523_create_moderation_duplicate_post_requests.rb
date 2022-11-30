class CreateModerationDuplicatePostRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :moderation_duplicate_post_requests do |t|
      t.references :post, null: false, foreign_key: true
      t.string :url, null: false
      t.string :reason, null: false
      t.datetime :approved_at, null: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
