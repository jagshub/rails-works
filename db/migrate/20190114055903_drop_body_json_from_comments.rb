class DropBodyJsonFromComments < ActiveRecord::Migration[5.0]
  def change
    remove_column :comments, :body_json
  end
end
