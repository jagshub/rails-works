class AddSourceToEmbeds < ActiveRecord::Migration
  def change
    add_column :embeds, :source, :text
  end
end
