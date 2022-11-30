class RenameRefererInVoteInfos < ActiveRecord::Migration[5.1]
  def change
    rename_column :vote_infos, :referer, :first_referer
    add_column :vote_infos, :referer, :text
  end
end
