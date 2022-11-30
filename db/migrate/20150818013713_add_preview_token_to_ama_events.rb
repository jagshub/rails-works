class AddPreviewTokenToAmaEvents < ActiveRecord::Migration
  def change
    add_column :ama_events, :preview_token, :string
  end
end
