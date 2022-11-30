class AddTcResourcesToMakersFestivalParticipant < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :makers_festival_participants, :receive_tc_resources, :boolean, null: false, default: false
    end
  end
end
