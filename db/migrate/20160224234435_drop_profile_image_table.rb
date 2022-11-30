class DropProfileImageTable < ActiveRecord::Migration
  def change
    drop_table :profile_images, force: :cascade
  end
end
