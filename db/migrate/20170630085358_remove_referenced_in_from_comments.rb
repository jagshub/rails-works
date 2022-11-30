class RemoveReferencedInFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :referenced_in_id, :integer
    remove_column :comments, :referenced_in_type, :string
  end
end
