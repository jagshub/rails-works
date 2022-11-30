class AddEnabledToHeroBlocks < ActiveRecord::Migration
  def change
    add_column :hero_blocks, :enabled, :boolean, null: false, default: false
  end
end
