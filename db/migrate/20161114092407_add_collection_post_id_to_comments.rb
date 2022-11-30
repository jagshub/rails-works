class AddCollectionPostIdToComments < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :comments, :referenced_in_id, :integer
    add_column :comments, :referenced_in_type, :string

    add_index :comments, %i(referenced_in_id referenced_in_type), algorithm: :concurrently
  end
end
