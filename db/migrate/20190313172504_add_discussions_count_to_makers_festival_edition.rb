class AddDiscussionsCountToMakersFestivalEdition < ActiveRecord::Migration[5.0]
  def change
    add_column :makers_festival_editions, :discussions_count, :integer, null: false, default: 0
  end
end
