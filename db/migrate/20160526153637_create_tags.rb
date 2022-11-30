class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.text :name, null: false
    end

    execute 'CREATE UNIQUE INDEX index_tags_on_lower_name ON tags(lower(name))'

    # NOTE (k1): Setting the starting id very high so that topics and categories can more easily occupy the lower space.
    execute "SELECT setval('tags_id_seq', 100000)"
  end

  def down
    execute 'DROP INDEX IF EXISTS index_tags_on_lower_name'

    drop_table :tags
  end
end
