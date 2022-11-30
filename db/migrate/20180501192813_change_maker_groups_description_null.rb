class ChangeMakerGroupsDescriptionNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :maker_groups, :description, false
  end
end
