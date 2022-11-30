class CreateAnnouncements < ActiveRecord::Migration[5.1]
  def change
    create_table :announcements do |t|
      t.boolean :active, null: false, default: false
      t.string :kind, null: false, default: 'text'
      t.string :image_uuid, null: true
      t.string :alt_text, null: true
      t.string :title, null: false
      t.string :href, null: false
      t.string :body_text, null: true
      t.string :cta_text, null: false, default: 'Learn More'
      t.date :active_until

      t.timestamps
    end
  end
end
