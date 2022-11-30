class AddRatingsCountToPost < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :ratings_count, :integer, :default => 0, null: false
  end
end
