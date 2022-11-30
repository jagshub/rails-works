class CreateSpamFilterValues < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_filter_values do |t|
      t.integer :filter_kind, null: false
      t.string :value, null: false
      t.integer :false_positive_count, null: false, default: 0
      t.text :note
      t.references :added_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end

    add_index :spam_filter_values, %i(value filter_kind), unique: true
  end
end
