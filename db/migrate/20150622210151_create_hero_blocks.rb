class CreateHeroBlocks < ActiveRecord::Migration
  def change
    create_table :hero_blocks do |t|
      t.string :link_url, null: false
      t.string :background_image, null: false
      t.belongs_to :category, index: true, null: false

      t.timestamps null: false
    end
  end
end
