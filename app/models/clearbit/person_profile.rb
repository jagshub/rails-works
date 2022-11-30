# frozen_string_literal: true

# == Schema Information
#
# Table name: clearbit_person_profiles
#
#  id                   :integer          not null, primary key
#  clearbit_id          :string           not null
#  email                :string           not null
#  indexed_at           :datetime         not null
#  name                 :string
#  gender               :string
#  bio                  :text
#  site                 :string
#  avatar_url           :string
#  employment_name      :string
#  employment_title     :string
#  employment_domain    :string
#  geo_city             :string
#  geo_state            :string
#  geo_country          :string
#  github_handle        :string
#  twitter_handle       :string
#  linkedin_handle      :string
#  gravatar_handle      :string
#  aboutme_handle       :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  employment_seniority :string
#  employment_role      :string
#
# Indexes
#
#  index_clearbit_person_profiles_clearbit_id  (clearbit_id)
#  index_clearbit_person_profiles_on_email     (email) UNIQUE
#
class Clearbit::PersonProfile < ApplicationRecord
  include Namespaceable

  validates :clearbit_id, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :indexed_at, presence: true

  has_many :ship_contacts,
           dependent: :nullify,
           foreign_key: :clearbit_person_profile_id,
           inverse_of: :clearbit_person_profile

  has_one :person_company,
          class_name: 'Clearbit::PeopleCompany',
          dependent: :destroy,
          foreign_key: :person_id,
          inverse_of: :person

  has_one :company,
          class_name: 'Clearbit::CompanyProfile',
          through: :person_company,
          source: :company
end
