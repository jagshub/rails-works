class AddPositionIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    return if Rails.env.production?

    add_index(
      :golden_kitty_people,
      %i(position golden_kitty_category_id),
      where: 'position is NOT NULL',
      unique: true,
      algorithm: :concurrently,
      name: 'index_gk_people_on_position_and_category_id'
    )
  end

  def down
    remove_index :golden_kitty_people, %i(position golden_kitty_category_id), if_exists: true
  end
end
