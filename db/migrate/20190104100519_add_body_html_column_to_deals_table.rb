class AddBodyHtmlColumnToDealsTable < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :body_html, :text
  end
end
