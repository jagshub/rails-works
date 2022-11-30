class CreateMeetupEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :meetup_events do |t|
      t.references :host, index: true, foreign_key: { to_table: :users }, null: false

      t.string :name, null: false
      t.string :description, null: false
      t.string :thumbnail_uuid, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.string :link, null: false
      t.datetime :date, null: false
      t.datetime :approved_at, null: true
      t.datetime :last_content_update_at, null: true

      t.timestamps
    end

    add_column :users, :ambassador, :boolean, null: true
    add_index :meetup_events, %i(approved_at last_content_update_at), where: 'approved_at IS NOT NULL'
  end
end
