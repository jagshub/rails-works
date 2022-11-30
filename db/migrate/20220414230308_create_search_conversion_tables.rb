class CreateSearchConversionTables < ActiveRecord::Migration[6.1]
  def change
    create_table :search_searchable_conversions do |t|
      t.references :searchable, polymorphic: true, index: true, null: false
      t.references :search_user_search, index: true, null: false
      t.datetime :converted_at, null: false
      t.string :source, null: false
    end

    create_table :search_user_searches do |t|
      t.references :user
      t.string :search_type, null: false
      t.string :query, null: false
      t.string :normalized_query, null: false
      t.integer :conversions_count, default: 0, null: false
      t.integer :results_count, default: 0, null: false

      t.timestamps
    end

    add_index :search_user_searches, [:created_at]
    add_index :search_user_searches, [:search_type, :created_at]
    add_index :search_user_searches,
              [:search_type, :normalized_query, :created_at],
              name: "index_search_user_searches_on_search_type_query"
  end
end
