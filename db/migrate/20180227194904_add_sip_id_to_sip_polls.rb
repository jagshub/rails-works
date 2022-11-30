class AddSipIdToSipPolls < ActiveRecord::Migration[5.0]
  def change
    add_reference :sip_polls, :sip, foreign_key: true
  end
end
