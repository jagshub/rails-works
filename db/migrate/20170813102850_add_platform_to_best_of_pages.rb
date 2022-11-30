class AddPlatformToBestOfPages < ActiveRecord::Migration
  def change
    add_column :best_of_pages, :platform, :integer, default: 0, null: false
  end
end
