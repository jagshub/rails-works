class AddScreenshotUrlToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :screenshot_url, :string
  end
end
