class AddExtrasToChangeLogMedia < ActiveRecord::Migration[5.1]
  def change
    add_column :change_log_media, :media_type, :string, null: false
    add_column :change_log_media, :original_width, :integer, null: false
    add_column :change_log_media, :original_height, :integer, null: false
    add_column :change_log_media, :metadata, :jsonb, null: false
  end
end
