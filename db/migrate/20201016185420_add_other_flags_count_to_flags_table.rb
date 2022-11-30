class AddOtherFlagsCountToFlagsTable < ActiveRecord::Migration[5.1]
  class Flag < ActiveRecord::Base; end

  def up
    add_column :flags, :other_flags_count, :integer
    change_column_default :flags, :other_flags_count, 0

    Flag.update_all other_flags_count: 0

    change_column_null :flags, :other_flags_count, false
  end

  def down
    remove_column :flags, :other_flags_count
  end
end
