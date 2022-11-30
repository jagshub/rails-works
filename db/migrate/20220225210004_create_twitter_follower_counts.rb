class CreateTwitterFollowerCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_follower_counts do |t|
      t.integer :subject_id, null: false
      t.string :subject_type, null: false
      t.integer :follower_count, default: 0, null: false
      t.datetime :last_checked, default: 'now()', null: false

      t.timestamps
      t.index([:subject_id, :subject_type], unique: true, name: :index_twitter_follower_counts_on_subject_and_id)
    end
  end
end
