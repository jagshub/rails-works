class DropMediaLegacyColumns < ActiveRecord::Migration[5.2]
  def change
    remove_index :media, name: :index_media_on_legacy_type_and_legacy_id
    safety_assured do
      remove_column :media, :legacy_id
      remove_column :media, :legacy_type
    end
  end
end
