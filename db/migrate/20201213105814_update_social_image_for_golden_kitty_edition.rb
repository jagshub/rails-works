class UpdateSocialImageForGoldenKittyEdition < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      remove_column :golden_kitty_editions, :social_image, :string, null: true
      remove_column :golden_kitty_editions, :social_image_nomination_started, :string, null: true
      remove_column :golden_kitty_editions, :social_image_nomination_ended, :string, null: true
      remove_column :golden_kitty_editions, :social_image_voting_started, :string, null: true
      remove_column :golden_kitty_editions, :social_image_voting_ended, :string, null: true
      remove_column :golden_kitty_editions, :social_image_result_announced, :string, null: true
      remove_column :golden_kitty_categories, :social_image_nomination_started, :string, null: true
      remove_column :golden_kitty_categories, :social_image_nomination_ended, :string, null: true
      remove_column :golden_kitty_categories, :social_image_voting_started, :string, null: true
      remove_column :golden_kitty_categories, :social_image_voting_ended, :string, null: true
      remove_column :golden_kitty_categories, :social_image_result_announced, :string, null: true

      add_column :golden_kitty_editions, :social_image_uuid, :string, null: true
      add_column :golden_kitty_editions, :social_image_nomination_uuid, :string, null: true
      add_column :golden_kitty_editions, :social_image_voting_uuid, :string, null: true
      add_column :golden_kitty_editions, :social_image_result_uuid, :string, null: true

      add_column :golden_kitty_categories, :social_image_nomination_uuid, :string, null: true
      add_column :golden_kitty_categories, :social_image_voting_uuid, :string, null: true
      add_column :golden_kitty_categories, :social_image_result_uuid, :string, null: true
    end
  end
end
