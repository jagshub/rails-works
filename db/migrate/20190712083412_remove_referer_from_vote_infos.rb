class RemoveRefererFromVoteInfos < ActiveRecord::Migration[5.1]
  def change
    remove_column :vote_infos, :referer
  end
end
