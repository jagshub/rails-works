class AddHeaderMediaIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :header_media_id, :integer
  end
end
