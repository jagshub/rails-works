class AddDescriptionToMakerGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_groups, :description, :string
  end
end
