class AddUniqueIndexToCompanyNames < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :companies, [:name], unique: true, algorithm: :concurrently
  end
end
