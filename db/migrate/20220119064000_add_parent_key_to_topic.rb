class AddParentKeyToTopic < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :topics, :topics, column: :parent_id, validate: false
  end
end
