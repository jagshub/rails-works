class RemoveBodyHtmlFromMessages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_page_messages, :body_html
  end
end
