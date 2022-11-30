class AddKindToTopic < ActiveRecord::Migration[6.1]
  def change
    add_column :topics, :kind, :integer, null: true
  end
end
