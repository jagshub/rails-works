class CreateMakerReports < ActiveRecord::Migration[5.0]
  def change
    create_table :maker_reports do |t|
      t.belongs_to :user, null: false
      t.belongs_to :post, null: false
      t.datetime :activity_created_after, null: false
      t.timestamps null: false
    end
  end
end
