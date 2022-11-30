class AddSeoColumnsToProductRequests < ActiveRecord::Migration
  def change
    add_column :product_requests, :seo_title, :text
    add_column :product_requests, :seo_description, :text
  end
end
