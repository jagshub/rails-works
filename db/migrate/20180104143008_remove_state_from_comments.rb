class RemoveStateFromComments < ActiveRecord::Migration[5.0]
  def change
    remove_column :comments, :state
  end
end
