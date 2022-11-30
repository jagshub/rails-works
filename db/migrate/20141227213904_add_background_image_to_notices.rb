class AddBackgroundImageToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :background_image, :string
    add_column :notices, :background_image_processing, :boolean, null: false, default: false
  end
end
