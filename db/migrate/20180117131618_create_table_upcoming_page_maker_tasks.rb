class CreateTableUpcomingPageMakerTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_maker_tasks do |t|
      t.string :kind, null: false

      t.references :upcoming_page, null: false, index: true
      t.datetime :completed_at, null: true
      t.references :completed_by_user, null: true, index: true

      t.timestamps null: false
    end
  end
end
