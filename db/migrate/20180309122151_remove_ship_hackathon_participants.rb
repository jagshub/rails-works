class RemoveShipHackathonParticipants < ActiveRecord::Migration[5.0]
  def change
    drop_table :ship_hackathon_participants
  end
end
