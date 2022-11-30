class AddTestIndexToPageContent < ActiveRecord::Migration[6.1]
  def change
    safety_assured { add_index :page_contents, %i(element_key page_key) }
  end
end
