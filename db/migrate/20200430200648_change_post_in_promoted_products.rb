class ChangePostInPromotedProducts < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :promoted_products, :post_id, :integer, null: true 
      add_column :promoted_products, :name, :string, null: true
      add_column :promoted_products, :tagline, :string, null: true
      add_column :promoted_products, :thumbnail_uuid, :uuid, null: true
    end
  end
end
