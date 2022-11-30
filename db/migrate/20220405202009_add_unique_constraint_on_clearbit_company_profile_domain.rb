class AddUniqueConstraintOnClearbitCompanyProfileDomain < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :clearbit_company_profiles, :domain, unique: true, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :clearbit_company_profiles, :domain, if_exists: true
  end
end
