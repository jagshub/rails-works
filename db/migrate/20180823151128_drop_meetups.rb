class DropMeetups < ActiveRecord::Migration[5.0]
  def change
    drop_table :meetups
    drop_table :meetup_host_associations
  end
end
