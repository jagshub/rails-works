class ChangeSettingValueFromStringToText < ActiveRecord::Migration[5.2]
  def change
    change_column :settings, :value, :text
  end

  def down
    change_column :settings, :value, :string
  end
end
