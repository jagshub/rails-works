class RemoveNullConstraintOnClearbitCompanyProfileName < ActiveRecord::Migration[6.1]
  def change
    change_column_null :clearbit_company_profiles, :name, true
  end
end
