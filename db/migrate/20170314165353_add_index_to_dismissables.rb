class AddIndexToDismissables < ActiveRecord::Migration
  def change
    add_index :dismissables, [:dismissable_group, :user_id]
  end
end
