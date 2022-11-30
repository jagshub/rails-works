class FinishFlagsReasonMigration < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      remove_column :flags, :reason, :integer
    }
    change_column_null :flags, :reason_new, false
    safety_assured {
      rename_column :flags, :reason_new, :reason
    }
  end
end
