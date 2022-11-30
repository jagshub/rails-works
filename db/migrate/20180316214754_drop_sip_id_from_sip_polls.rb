class DropSipIdFromSipPolls < ActiveRecord::Migration[5.0]
  def change
    remove_column :sip_polls, :sip_id
  end
end
