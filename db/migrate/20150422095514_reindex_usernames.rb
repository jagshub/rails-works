class ReindexUsernames < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    remove_index :maker_suggestions, name: 'maker_suggestions_post_maker', algorithm: :concurrently
    add_index :maker_suggestions, [:post_id, :maker_id], unique: true, algorithm: :concurrently
    add_index :maker_suggestions, [:post_id, :maker_username], unique: true, algorithm: :concurrently
  end

  def down
    add_index :maker_suggestions, [:post_id, :maker_id, :maker_username], unique: true, name: 'maker_suggestions_post_maker', algorithm: :concurrently
    remove_index :maker_suggestions, [:post_id, :maker_id], algorithm: :concurrently
    remove_index :maker_suggestions, [:post_id, :maker_username], algorithm: :concurrently
  end
end
