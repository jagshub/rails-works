class AddMakersCountToPost < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :makers_count, :integer, null: false, default: 0
  end
end
