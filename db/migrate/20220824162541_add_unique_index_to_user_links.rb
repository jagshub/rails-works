class AddUniqueIndexToUserLinks < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :users_links, %i(user_id url), unique: true, algorithm: :concurrently, if_not_exists: true
  end
end
