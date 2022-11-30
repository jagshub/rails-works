class AddVotesCountToSipPollOption < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_poll_options, :sip_poll_votes_count, :integer, default: 0
  end
end
