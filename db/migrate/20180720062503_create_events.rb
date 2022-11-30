class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :external_url
      t.string :image_uuid, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.boolean :free, default: true
      t.integer :suscriber_count, null: false, default: 0
      t.decimal :latitude
      t.decimal :longitude
      t.string :country, null: false
      t.string :city, null: false
      t.string :address
    end

    add_index :events, :slug, unique: true
  end
end
