class AddCaptureEmailFlagToDeal < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :capture_email, :boolean, null: false, default: true
  end
end
