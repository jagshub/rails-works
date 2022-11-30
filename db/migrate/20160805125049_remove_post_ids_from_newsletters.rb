class RemovePostIdsFromNewsletters < ActiveRecord::Migration
  def change
    remove_column :newsletters, :post_ids
  end
end
