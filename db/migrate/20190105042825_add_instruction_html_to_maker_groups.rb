class AddInstructionHtmlToMakerGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_groups, :instructions_html, :text
  end
end
