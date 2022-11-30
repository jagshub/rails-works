class RemovePlatforms < ActiveRecord::Migration
  def change
    drop_table :category_platform_associations
    drop_table :product_platform_associations
    drop_table :platforms
  end
end
