class AddActivityCreatedBeforeToMakerReports < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_reports, :activity_created_before, :datetime, null: false
  end
end
