class RemoveGkDuplicateIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :golden_kitty_edition_sponsors, name: "index_golden_kitty_edition_sponsors_on_edition_id", column: :edition_id
  end
end
