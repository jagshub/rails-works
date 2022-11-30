class AddAppOfTheDayFeaturedAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :ios_featured_at, :datetime
  end
end
