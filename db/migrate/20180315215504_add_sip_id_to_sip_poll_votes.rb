class AddSipIdToSipPollVotes < ActiveRecord::Migration[5.0]
  def change
    add_reference :sip_poll_votes, :sip, foreign_key: true, null: false
  end
end
