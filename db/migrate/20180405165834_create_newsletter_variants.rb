class CreateNewsletterVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :newsletter_variants do |t|
      t.references :newsletter_experiment, null: false, foreign_key: true
      t.integer :variant_winner, null: false, default: 0
      t.jsonb :sections
      t.string :subject
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
