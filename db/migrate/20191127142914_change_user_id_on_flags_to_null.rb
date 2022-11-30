class ChangeUserIdOnFlagsToNull < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :flags, :user_id, :integer, :null => true
      remove_index :flags, column: %i(subject_type subject_id user_id)
    end
  end
end
