class AddPostVoteCheckResults < ActiveRecord::Migration
  def change
    create_table :post_vote_check_results do |t|
      t.references :post_vote, null: false
      t.integer :check, null: false
      t.integer :spam_score, default: 0, null: false
      t.integer :vote_ring_score, default: 0, null: false
    end

    add_index :post_vote_check_results, [:post_vote_id, :check], unique: true
  end
end
