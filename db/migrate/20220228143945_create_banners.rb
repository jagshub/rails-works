# frozen_string_literal: true

class CreateBanners < ActiveRecord::Migration[6.1]
  def change
    create_table :banners do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :status, null: false, default: 'active'
      t.string :position, null: false, default: 'mainfeed'
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.text :description
      t.string :desktop_image_uuid, null: false
      t.string :wide_image_uuid, null: false
      t.string :tablet_image_uuid, null: false
      t.string :mobile_image_uuid, null: false
      t.string :url, null: false

      t.index :status, name: :banner_status
      t.index :position, name: :banner_position

      t.timestamps
    end
  end
end
