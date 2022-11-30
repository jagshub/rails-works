class AddPreviewTokenToNewsletters < ActiveRecord::Migration[5.0]
  def change
    add_column :newsletters, :preview_token, :string
  end
end
