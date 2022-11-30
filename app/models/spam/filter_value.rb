# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_filter_values
#
#  id                   :bigint(8)        not null, primary key
#  filter_kind          :integer          not null
#  value                :string           not null
#  false_positive_count :integer          default(0), not null
#  note                 :text
#  added_by_id          :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_spam_filter_values_on_added_by_id            (added_by_id)
#  index_spam_filter_values_on_value_and_filter_kind  (value,filter_kind) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (added_by_id => users.id)
#

class Spam::FilterValue < ApplicationRecord
  include Namespaceable

  before_validation :format_value

  belongs_to :added_by, class_name: '::User', optional: true, inverse_of: :spam_filter_values

  has_many :rule_logs, class_name: '::Spam::RuleLog', inverse_of: :filter_value, foreign_key: :spam_filter_value_id, dependent: :destroy

  enum filter_kind: SpamChecks.filter_kind_enums

  validates :value, presence: true, uniqueness: { scope: :filter_kind }
  validates :filter_kind, presence: true
  validates :added_by_id, presence: true, on: :create

  private

  def format_value
    self.value = SpamChecks.format_filter_value(filter_kind, value)
  rescue ArgumentError => e
    errors.add(:value, e.message)
  end
end
