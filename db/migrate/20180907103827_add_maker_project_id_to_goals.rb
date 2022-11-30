class AddMakerProjectIdToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :maker_project_id, :integer, null: true
    add_index :goals, :maker_project_id
    add_foreign_key :goals, :maker_projects
  end
end
