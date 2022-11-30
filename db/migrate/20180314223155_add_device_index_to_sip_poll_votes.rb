class AddDeviceIndexToSipPollVotes < ActiveRecord::Migration[5.0]
  def change
    add_index :sip_poll_votes, :device
  end
end
