class AddSocialImageToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :social_image_url, :string, null: true
  end
end
