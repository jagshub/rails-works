class CreateShipTracking < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_tracking_identities  do |t|
      t.string :visitor_id, null: true, index: { unique: true }
      t.belongs_to :user, null: true, index: true, foreign_key: true

      t.string :source, null: true
      t.string :campaign, null: true
      t.string :medium, null: true

      t.timestamps
    end

    create_table :ship_tracking_events do |t|
      t.belongs_to :ship_tracking_identity, foreign_key: true, index: true, null: false
      t.string :funnel_step, null: false, index: true
      t.string :event_name, null: false
      t.jsonb :meta, null: false, default: '{}'
    end
  end
end
