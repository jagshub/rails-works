class AddVotingEndedSocialToGoldenKitty < ActiveRecord::Migration[5.1]
  def change
    add_column :golden_kitty_editions, :social_image_pre_voting_uuid, :string, null: true
    add_column :golden_kitty_editions, :social_image_pre_result_uuid, :string, null: true

    add_column :golden_kitty_categories, :social_image_pre_voting_uuid, :string, null: true
    add_column :golden_kitty_categories, :social_image_pre_result_uuid, :string, null: true
  end
end
