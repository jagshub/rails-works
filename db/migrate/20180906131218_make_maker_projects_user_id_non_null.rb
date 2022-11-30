class MakeMakerProjectsUserIdNonNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :maker_projects, :user_id, false
  end
end
