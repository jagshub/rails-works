class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :subject_type, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false, index: true
      t.integer :sentiment, null: true
      t.jsonb :pros, null: true
      t.jsonb :cons, null: true
      t.jsonb :body, null: true

      t.integer :votes_count, null: false, default: 0, index: true
      t.integer :credible_votes_count, null: false, default: 0, index: true
      t.timestamps
    end

    add_index :reviews, [:subject_type, :subject_id, :user_id], unique: true
  end
end
