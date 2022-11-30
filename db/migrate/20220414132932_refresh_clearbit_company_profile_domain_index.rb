class RefreshClearbitCompanyProfileDomainIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    remove_index :clearbit_company_profiles, :domain, if_exists: true
    add_index :clearbit_company_profiles, :domain, unique: true, algorithm: :concurrently
  end

  def down
    # Do nothing
  end
end
