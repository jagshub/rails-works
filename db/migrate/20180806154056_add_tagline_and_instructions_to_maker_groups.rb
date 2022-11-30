class AddTaglineAndInstructionsToMakerGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_groups, :tagline, :string
    add_column :maker_groups, :instructions, :jsonb
  end
end
