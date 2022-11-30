class ChangeMakerActivityGroupColumn < ActiveRecord::Migration[5.1]
  def change
    change_column_null :maker_activities, :maker_group_id, false
  end
end
