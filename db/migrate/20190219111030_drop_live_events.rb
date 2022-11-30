class DropLiveEvents < ActiveRecord::Migration[5.0]
  def change
    drop_table :ama_events
    drop_table :ama_event_guest_associations
    drop_table :ama_event_subscriptions
  end
end
