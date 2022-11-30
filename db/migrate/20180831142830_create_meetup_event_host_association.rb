class CreateMeetupEventHostAssociation < ActiveRecord::Migration[5.0]
  def change
    create_table :meetup_event_host_associations do |t|
      t.references :meetup_event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps null: false
    end

    add_index :meetup_event_host_associations, [:meetup_event_id, :user_id], unique: true, name: :index_meetup_event_host_associations
  end
end
