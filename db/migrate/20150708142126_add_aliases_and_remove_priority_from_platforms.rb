class AddAliasesAndRemovePriorityFromPlatforms < ActiveRecord::Migration
  def change
    add_column :platforms, :aliases, :string, array: true, default: [], null: false
    remove_column :platforms, :priority, :integer, default: 0, null: false
  end
end
