class AddRequestInfoToVoteInfos < ActiveRecord::Migration[5.1]
  def change
    add_column :vote_infos, :user_agent, :text
    add_column :vote_infos, :device_type, :text
    add_column :vote_infos, :os, :text
    add_column :vote_infos, :browser, :text
    add_column :vote_infos, :country, :text
  end
end
