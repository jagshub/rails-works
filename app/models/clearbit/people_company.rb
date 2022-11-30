# frozen_string_literal: true

# == Schema Information
#
# Table name: clearbit_people_companies
#
#  id         :bigint(8)        not null, primary key
#  person_id  :bigint(8)        not null
#  company_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_clearbit_people_companies_on_company_id  (company_id)
#  index_clearbit_people_companies_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => clearbit_company_profiles.id)
#  fk_rails_...  (person_id => clearbit_person_profiles.id)
#
class Clearbit::PeopleCompany < ApplicationRecord
  include Namespaceable

  belongs_to :person,
             class_name: 'Clearbit::PersonProfile',
             inverse_of: :person_company

  belongs_to :company,
             class_name: 'Clearbit::CompanyProfile',
             inverse_of: :company_people
end
