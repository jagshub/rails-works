# frozen_string_literal: true

class CreateDiscussionCategoryAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :discussion_category_associations do |t|
      t.references :category, null: false, index: true, foreign_key: { to_table: :discussion_categories }
      t.references :discussion_thread, null: false, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
