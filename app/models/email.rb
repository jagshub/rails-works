# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id                  :integer          not null, primary key
#  email               :citext           not null
#  source_kind         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  source_reference_id :string
#
# Indexes
#
#  index_emails_on_email                                (email)
#  index_emails_on_source_kind_and_source_reference_id  (source_kind,source_reference_id)
#

class Email < ApplicationRecord
  HasEmailField.define self
end
