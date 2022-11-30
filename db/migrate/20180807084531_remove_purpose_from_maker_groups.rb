class RemovePurposeFromMakerGroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :maker_groups, :purpose
  end
end
