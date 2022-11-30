class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.decimal :number, default: 0, null: false
      t.string :name, null: false
      t.date :date, null: false
      t.timestamps
    end

    add_index :metrics, [:name]
    add_index :metrics, [:name, :date]
  end
end
