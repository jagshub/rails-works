class RemoveTestIndexFromPageContent < ActiveRecord::Migration[6.1]
  def change
    remove_index :page_contents, %i(element_key page_key)
  end
end
