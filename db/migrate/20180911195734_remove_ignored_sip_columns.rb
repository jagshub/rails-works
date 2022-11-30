class RemoveIgnoredSipColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :sips, :intro_background
    remove_column :sips, :thumbnail
    remove_column :sip_slides, :article_icon
    remove_column :sip_slides, :intro_background
    remove_column :sip_slides, :photo
  end
end
