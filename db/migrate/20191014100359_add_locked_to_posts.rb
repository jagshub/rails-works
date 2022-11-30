class AddLockedToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :locked, :boolean, null: true
  end
end
