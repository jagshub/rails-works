class AddImageUuidToCollecitons < ActiveRecord::Migration
  def change
    add_column :collections, :image_uuid, :uuid, null: true
  end
end
