class AddCommentsCountToSips < ActiveRecord::Migration[5.0]
  def change
    add_column :sips, :comments_count, :integer, null: false, default: 0
    add_index :sips, :comments_count
  end
end
