class AddHiddenAtToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :hidden_at, :datetime, null: true
  end
end
