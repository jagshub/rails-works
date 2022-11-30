class AddParentIdToInputSuggestion < ActiveRecord::Migration[5.0]
  def change
    add_column :input_suggestions, :parent_id, :integer

    add_foreign_key :input_suggestions, :input_suggestions, column: :parent_id
    add_index :input_suggestions, :parent_id
  end
end
