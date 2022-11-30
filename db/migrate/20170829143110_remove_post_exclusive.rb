class RemovePostExclusive < ActiveRecord::Migration
  def change
    remove_column :posts, :exclusive_text
    remove_column :posts, :exclusive_maker_id
  end
end
