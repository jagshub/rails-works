class AddIndexOnClearbitPersonProfilesClearbitId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :clearbit_person_profiles, :clearbit_id, name: "index_clearbit_person_profiles_clearbit_id", algorithm: :concurrently
  end
end
