class AddSipPollVotesCountToSipPolls < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_polls, :sip_poll_votes_count, :integer
  end
end
