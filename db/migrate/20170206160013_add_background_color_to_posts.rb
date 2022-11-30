class AddBackgroundColorToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :background_color, :string
  end
end
