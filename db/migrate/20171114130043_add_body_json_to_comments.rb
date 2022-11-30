class AddBodyJsonToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :body_json, :jsonb
  end
end
