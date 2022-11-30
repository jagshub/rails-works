class DropSipIdFromSipPollVotes < ActiveRecord::Migration[5.0]
  def change
    remove_column :sip_poll_votes, :sip_id
  end
end
