class CreateAnthologiesStory < ActiveRecord::Migration[5.0]
  def change
    create_table :anthologies_stories do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :header_image_uuid
      t.integer :mins_to_read, default: 0
      t.string :description, maximum: 255
      t.text :body_html
      t.belongs_to :user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
