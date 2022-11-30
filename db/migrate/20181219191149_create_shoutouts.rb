class CreateShoutouts < ActiveRecord::Migration[5.0]
  def change
    create_table :shoutouts do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.text :body, null: false
      t.datetime :trashed_at, null: true
      t.integer :votes_count, null: false, default: 0
      t.integer :credible_votes_count, null: false, default: 0
      t.timestamps null: false
    end
  end
end
