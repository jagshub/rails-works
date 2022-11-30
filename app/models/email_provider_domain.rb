# frozen_string_literal: true

# == Schema Information
#
# Table name: email_provider_domains
#
#  id          :bigint(8)        not null, primary key
#  value       :string           not null
#  added_by_id :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_email_provider_domains_on_added_by_id  (added_by_id)
#  index_email_provider_domains_on_value        (value)
#
class EmailProviderDomain < ApplicationRecord
  belongs_to :added_by, class_name: 'User'

  validates :value, presence: true, uniqueness: true
end
