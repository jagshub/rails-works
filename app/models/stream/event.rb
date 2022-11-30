# frozen_string_literal: true

# == Schema Information
#
# Table name: stream_events
#
#  id               :bigint(8)        not null, primary key
#  source           :integer          default("web"), not null
#  name             :string           not null
#  source_path      :string
#  source_component :string
#  subject_type     :string
#  subject_id       :bigint(8)
#  user_id          :bigint(8)
#  payload          :jsonb            not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  received_at      :datetime         not null
#
# Indexes
#
#  index_stream_events_on_name                         (name)
#  index_stream_events_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_stream_events_on_user_id                      (user_id)
#

class Stream::Event < ApplicationRecord
  include Namespaceable

  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :name, presence: true

  enum source: { web: 0, api: 1, mobile: 2, admin: 3, application: 4, android: 5, ios: 6 }
end
