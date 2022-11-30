class ChangeMakerGroupsTaglineNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :maker_groups, :tagline, false
  end
end
