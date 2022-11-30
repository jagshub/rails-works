class CreateNewsletterExperiments < ActiveRecord::Migration[5.0]
  def change
    create_table :newsletter_experiments do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :test_count, null: false

      t.timestamps
    end
  end
end
