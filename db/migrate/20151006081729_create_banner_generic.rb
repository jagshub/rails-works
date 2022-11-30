class CreateBannerGeneric < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      # NOTE(vesln): core
      t.text :type, null: false
      t.text :subject_type, null: true
      t.integer :subject_id, null: true
      t.boolean :enabled, null: false, default: false
      t.jsonb :conditions, null: false, default: {}
      t.text :browsers, array: true, default: []

      # NOTE(vesln): generic specific
      t.text :title, null: true
      t.text :body_text, null: true
      t.text :link_url, null: true
      t.uuid :background_image_uuid, null: true

      # NOTE(vesln): meta attributes
      t.timestamps null: false
    end
  end
end
