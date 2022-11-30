class AddProductToJobs < ActiveRecord::Migration[6.1]
  def change
    add_column :jobs, :product_id, :bigint, null: true, index: true

    # Note(AR): Validate: false by recommendation of strong_migrations, will
    # add another migration for foreign key validation.
    add_foreign_key :jobs, :products, on_delete: :nullify, validate: false
  end
end
