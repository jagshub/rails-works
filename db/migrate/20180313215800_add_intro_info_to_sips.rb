class AddIntroInfoToSips < ActiveRecord::Migration[5.0]
  def change
    add_column :sips, :intro_title, :text, default: "", null: false
    add_column :sips, :intro_background, :text
    add_column :sips, :intro_description, :text
  end
end
