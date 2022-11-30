class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.string :description, null: false, default: ''
      t.string :slug, null: false
      t.timestamps null: false
    end

    create_table :topic_aliases do |t|
      t.integer :topic_id, null: false
      t.string :name, null: false
      t.timestamps null: false
    end

    add_foreign_key :topic_aliases, :topics

    add_index :topics, :slug, unique: true

    add_index :topic_aliases, :name, unique: true, name: 'index_topic_aliases_on_name_unique'

    # Note(rstankov): Fast full text searching
    # - http://www.postgresql.org/docs/9.1/static/pgtrgm.html
    add_index :topic_aliases, :name, using: :gin, order: { name: :gin_trgm_ops }
  end
end

