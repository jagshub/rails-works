class CreateExternalAPIResponse < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :external_api_responses do |t|
      t.string :kind, null: false
      t.jsonb :params, default: {}, null: false
      t.json :response, default: {}, null: false

      t.timestamps
    end

    add_index(
      :external_api_responses,
      [:params, :kind],
      using: :gin,
      algorithm: :concurrently,
    )
  end
end
