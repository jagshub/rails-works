class AddHideToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :hide, :boolean
  end
end
