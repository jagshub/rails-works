class AddPostVoteInfoVisitDuration < ActiveRecord::Migration
  def change
    add_column :post_vote_infos, :visit_duration, :integer, null: true
  end
end
