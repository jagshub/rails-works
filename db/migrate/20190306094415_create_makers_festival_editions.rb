class CreateMakersFestivalEditions < ActiveRecord::Migration[5.0]
  def change
    create_table :makers_festival_editions do |t|
      t.date :start_date, null: false
      t.string :sponsor, null: false

      t.timestamps
    end

    add_index :makers_festival_editions, :start_date, unique: true
  end
end
