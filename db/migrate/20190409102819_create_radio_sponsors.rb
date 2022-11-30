class CreateRadioSponsors < ActiveRecord::Migration[5.1]
  def change
    create_table :radio_sponsors do |t|
      t.string :name, null: false
      t.string :link, null: false
      t.uuid :image_uuid, null: false
      t.datetime :start_datetime, null: false
      t.datetime :end_datetime, null: false
      t.jsonb :image_properties, null: false, default: {}

      t.timestamps
    end

    add_index :radio_sponsors, %i(start_datetime end_datetime)
  end
end
