class CreateAbTestCompletionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :ab_test_completion_logs do |t|
      t.integer :subject_id, null: false
      t.string :subject_type, null: false
      t.string :ab_variant, null: false
      t.string :ab_test, null: false


      t.timestamps
    end
  end
end
