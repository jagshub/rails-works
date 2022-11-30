class CreateUpcomingPages < ActiveRecord::Migration
  def change
    create_table :upcoming_pages do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.jsonb :who_text
      t.jsonb :what_text
      t.jsonb :why_text
      t.jsonb :success_text

      t.string :facebook_link
      t.string :angellist_link
      t.string :twitter_link

      t.string :logo_uuid
      t.string :background_image_uuid

      t.boolean :hiring

      t.references :user, null: false
      t.timestamps null: false
    end

    add_index :upcoming_pages, :slug, unique: true
  end
end
