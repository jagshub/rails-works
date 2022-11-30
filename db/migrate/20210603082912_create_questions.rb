class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :post, index: true, foreign_key: true, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :title, null: false
      t.text :answer, null: false

      t.timestamps
    end
  end
end
