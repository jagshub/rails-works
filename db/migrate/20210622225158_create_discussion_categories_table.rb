# frozen_string_literal: true

class CreateDiscussionCategoriesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :discussion_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :description, null: false, default: ''
      t.string :thumbnail_uuid, null: true
      t.integer :discussion_thread_count, null: false, default: 0

      t.timestamps
    end

    add_index :discussion_categories, :name, unique: true
    add_index :discussion_categories, :slug, unique: true
  end
end
