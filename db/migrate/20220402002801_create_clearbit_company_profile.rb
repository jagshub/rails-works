class CreateClearbitCompanyProfile < ActiveRecord::Migration[6.1]
  def change
    create_table :clearbit_company_profiles do |t|
      t.string :domain, unique: true, null: false
      t.string :name, null: false
      t.string :clearbit_id, null: false
      t.string :legal_name
      t.string :category_sector
      t.string :category_industry
      t.string :category_sub_industry
      t.string :geo_country
      t.string :metrics_employees
      t.string :metrics_employees_range
      t.string :metrics_estimated_annual_revenue
      t.string :founded_year
      t.datetime :indexed_at

      t.timestamps
    end

    create_table :clearbit_people_companies do |t|
      t.references :person,
                   references: :clearbit_person_profiles,
                   foreign_key: { to_table: :clearbit_person_profiles },
                   null: false

      t.references :company,
                   references: :clearbit_company_profiles,
                   foreign_key: { to_table: :clearbit_company_profiles },
                   null: false

      t.timestamps
    end
  end
end
