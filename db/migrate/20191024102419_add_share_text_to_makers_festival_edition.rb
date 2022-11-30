class AddShareTextToMakersFestivalEdition < ActiveRecord::Migration[5.1]
  def change
    add_column :makers_festival_editions, :share_text, :text, null: true
  end
end
