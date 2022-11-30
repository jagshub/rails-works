class RemoveNullConstraintOnSlateFields < ActiveRecord::Migration[5.0]
  def change
    change_column_null :goals, :title, :true
  end
end
