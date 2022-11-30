class AddResultUrlToMakersFestivalEdition < ActiveRecord::Migration[5.1]
  def change
    add_column :makers_festival_editions, :result_url, :string, null: true
  end
end
