# frozen_string_literal: true

# == Schema Information
#
# Table name: clearbit_company_profiles
#
#  id                               :bigint(8)        not null, primary key
#  domain                           :string           not null
#  name                             :string
#  clearbit_id                      :string           not null
#  legal_name                       :string
#  category_sector                  :string
#  category_industry                :string
#  category_sub_industry            :string
#  geo_country                      :string
#  metrics_employees                :string
#  metrics_employees_range          :string
#  metrics_estimated_annual_revenue :string
#  founded_year                     :string
#  indexed_at                       :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
# Indexes
#
#  index_clearbit_company_profiles_on_domain  (domain) UNIQUE
#
class Clearbit::CompanyProfile < ApplicationRecord
  include Namespaceable

  has_many :company_people,
           class_name: 'Clearbit::PeopleCompany',
           dependent: :destroy,
           foreign_key: :company_id,
           inverse_of: :company

  has_many :people,
           class_name: 'Clearbit::PersonProfile',
           through: :company_people,
           source: :person
end
