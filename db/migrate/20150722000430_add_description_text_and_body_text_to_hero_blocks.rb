class AddDescriptionTextAndBodyTextToHeroBlocks < ActiveRecord::Migration
  def change
    add_column :hero_blocks, :body_text, :string
    add_column :hero_blocks, :description_text, :string
  end
end
