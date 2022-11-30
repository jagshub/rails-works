class AddSubjectIndexToMakerActivity < ActiveRecord::Migration[5.1]
  def change 
    change_column_null :maker_activities, :goal_id, true
    change_column_null :maker_activities, :subject_id, false
    change_column_null :maker_activities, :subject_type, false

    add_column :maker_activities, :hidden_at, :datetime, null: true

    add_index :maker_activities, %i(subject_id subject_type)
    add_index :maker_activities, :hidden_at
  end
end
