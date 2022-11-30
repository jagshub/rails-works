class AddTitleToNewsletter < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletters, :title, :string, null: true
  end
end
