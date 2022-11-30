class AddCredibleToPostVotes < ActiveRecord::Migration
  def change
    # Avoid wrapping transaction (CONCURRENTLY can't run inside transactions)
    reversible {|d| d.up { execute 'commit;' } }

    add_column :post_votes, :credible, :boolean, default: true, null: false
    add_index :post_votes, [:post_id, :credible], algorithm: :concurrently

    # Start a new transaction so Rails doesn't get confused
    reversible {|d| d.up { execute 'begin;' } }
  end
end
