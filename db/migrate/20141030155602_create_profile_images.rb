class CreateProfileImages < ActiveRecord::Migration
  def change
    create_table :profile_images do |t|
      t.string :file, null: false
      t.timestamps
    end

    add_reference :users, :profile_image, index: true
    add_foreign_key :users, :profile_images, dependant: :delete
  end
end
