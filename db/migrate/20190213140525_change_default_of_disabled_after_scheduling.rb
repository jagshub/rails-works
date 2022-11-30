class ChangeDefaultOfDisabledAfterScheduling < ActiveRecord::Migration[5.0]
  def change
    change_column_default :posts, :disabled_when_scheduled, from: false, to: true
  end
end
