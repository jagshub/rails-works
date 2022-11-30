class AddArticleIconUuidToSipSlides < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_slides, :article_icon_uuid, :uuid
  end
end
