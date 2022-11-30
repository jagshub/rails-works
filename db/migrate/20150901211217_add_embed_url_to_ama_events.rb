class AddEmbedUrlToAmaEvents < ActiveRecord::Migration
  def change
    add_column :ama_events, :video_stream_embed_url, :text
  end
end
