class AddTopicToGoldenKittyCategories < ActiveRecord::Migration[5.0]
  def change
    add_reference :golden_kitty_categories, :topic, foreign_key: true, null: true
  end
end
