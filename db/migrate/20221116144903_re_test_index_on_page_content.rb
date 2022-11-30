class ReTestIndexOnPageContent < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :page_contents, %i(element_key page_key)

    add_index :page_contents, %i(element_key page_key), algorithm: :concurrently
  end
end
