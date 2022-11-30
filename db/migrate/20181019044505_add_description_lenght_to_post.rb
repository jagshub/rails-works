class AddDescriptionLenghtToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :description_length, :integer, default: 0, null: false
  end
end
