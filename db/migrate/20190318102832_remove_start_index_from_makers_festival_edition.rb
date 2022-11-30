class RemoveStartIndexFromMakersFestivalEdition < ActiveRecord::Migration[5.0]
  def up
    remove_index :makers_festival_editions, :start_date
    add_index :makers_festival_editions, :start_date
  end

  def down
    remove_index :makers_festival_editions
    add_index :makers_festival_editions, :start_date, unique: true
  end
end
