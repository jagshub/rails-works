# frozen_string_literal: true

# == Schema Information
#
# Table name: seo_structured_data_validation_messages
#
#  id           :integer          not null, primary key
#  subject_type :string           not null
#  subject_id   :integer          not null
#  messages     :string           default([]), not null, is an Array
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_seo_structured_data_validaton_on_subject  (subject_type,subject_id)
#

class SeoStructuredDataValidationMessages < ApplicationRecord
  belongs_to :subject, polymorphic: true
end
