class RemoveSipPollIdFromSipSlides < ActiveRecord::Migration[5.0]
  def change
    remove_column :sip_slides, :sip_poll_id
  end
end
