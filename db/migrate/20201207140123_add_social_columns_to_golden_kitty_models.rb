class AddSocialColumnsToGoldenKittyModels < ActiveRecord::Migration[5.1]
  def change
    add_column :golden_kitty_editions, :social_image_nomination_started, :string, null: true
    add_column :golden_kitty_editions, :social_image_nomination_ended, :string, null: true
    add_column :golden_kitty_editions, :social_image_voting_started, :string, null: true
    add_column :golden_kitty_editions, :social_image_voting_ended, :string, null: true
    add_column :golden_kitty_editions, :social_image_result_announced, :string, null: true

    add_column :golden_kitty_editions, :social_text_nomination_started, :string, null: true
    add_column :golden_kitty_editions, :social_text_nomination_ended, :string, null: true
    add_column :golden_kitty_editions, :social_text_voting_started, :string, null: true
    add_column :golden_kitty_editions, :social_text_voting_ended, :string, null: true
    add_column :golden_kitty_editions, :social_text_result_announced, :string, null: true

    add_column :golden_kitty_categories, :social_image_nomination_started, :string, null: true
    add_column :golden_kitty_categories, :social_image_nomination_ended, :string, null: true
    add_column :golden_kitty_categories, :social_image_voting_started, :string, null: true
    add_column :golden_kitty_categories, :social_image_voting_ended, :string, null: true
    add_column :golden_kitty_categories, :social_image_result_announced, :string, null: true
  end
end
