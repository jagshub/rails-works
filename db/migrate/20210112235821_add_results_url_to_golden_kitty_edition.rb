class AddResultsUrlToGoldenKittyEdition < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :golden_kitty_editions, :results_url, :string, null: true
      add_column :golden_kitty_editions, :results_description, :string, null: true
    end
  end
end
