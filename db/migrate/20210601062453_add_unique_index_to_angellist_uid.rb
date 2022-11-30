class AddUniqueIndexToAngellistUid < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :users, :angellist_uid, unique: true, algorithm: :concurrently
  end
end
