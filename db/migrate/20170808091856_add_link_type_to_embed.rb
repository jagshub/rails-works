class AddLinkTypeToEmbed < ActiveRecord::Migration
  def change
    add_column :embeds, :link_type, :integer, default: 0, null: false
  end
end
