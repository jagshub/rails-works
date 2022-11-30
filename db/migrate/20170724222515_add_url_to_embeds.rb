class AddUrlToEmbeds < ActiveRecord::Migration
  def change
    add_column :embeds, :url, :string
  end
end
