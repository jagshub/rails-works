class AddVotingEnabledAtToGoldenKittyCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :golden_kitty_categories, :voting_enabled_at, :datetime, null: true
  end
end
