class AddFaviconToEmbed < ActiveRecord::Migration
  def change
    add_column :embeds, :favicon_image_uuid, :uuid
  end
end
