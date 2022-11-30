class DropHeroBlocksTable < ActiveRecord::Migration
  def change
    drop_table :hero_blocks
  end
end
