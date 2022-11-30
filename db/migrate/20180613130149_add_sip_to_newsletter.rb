class AddSipToNewsletter < ActiveRecord::Migration[5.0]
  def change
    add_column :newsletters, :sips, :integer, array: true, default: []
  end
end
