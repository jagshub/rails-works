class CreateChangeLog < ActiveRecord::Migration[5.1]
  def change
    create_table :change_logs do |t|
      t.string :slug, null: false
      t.string :state, null: false, default: 'pending'
      t.string :title, null: false
      t.string :description, null: true
      t.date :date

      t.timestamps
    end

    add_index :change_logs,
              :date,
              where: "state = 'published'",
              name: :index_published_change_logs_date
  end
end
