# frozen_string_literal: true

class CreatePostDraftsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :post_drafts do |t|
      t.references :user, index: true, null: false
      t.references :post, index: true, null: true
      t.string :uuid, index: { unique: true }, null: false
      t.string :url, null: false
      t.jsonb :data, default: {}, null: false

      t.timestamps null: false
    end
  end
end
