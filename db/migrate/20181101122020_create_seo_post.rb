class CreateSeoPost < ActiveRecord::Migration[5.0]
  def change
    create_table :seo_posts do |t|
      t.belongs_to :post, index: true
      t.string :query, null: false
      t.float :ctr, default: 0
      t.float :position, default: 0
      t.integer :clicks, default: 0
      t.integer :impressions, default: 0
      t.timestamps null: false
    end
  end
end
