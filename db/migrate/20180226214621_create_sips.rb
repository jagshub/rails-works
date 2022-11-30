class CreateSips < ActiveRecord::Migration[5.0]
  def change
    create_table :sips do |t|
      t.text :description, null: false
      t.string :thumbnail
      t.string :topic
      t.datetime :published_at

      t.timestamps
    end
  end
end
