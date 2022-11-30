class AddImageUuidToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :image_uuid, :uuid, null: true
  end
end
