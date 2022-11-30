class AddPostVoteInfos < ActiveRecord::Migration
  def change
    create_table :post_vote_infos do |t|
      t.references :post_vote, null: false
      t.inet :request_ip
      t.text :referer
      t.references :oauth_application
    end

    add_index :post_vote_infos, :post_vote_id, unique: true
  end
end
