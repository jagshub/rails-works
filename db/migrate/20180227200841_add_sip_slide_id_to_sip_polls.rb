class AddSipSlideIdToSipPolls < ActiveRecord::Migration[5.0]
  def change
    add_reference :sip_polls, :sip_slide, foreign_key: true
  end
end
