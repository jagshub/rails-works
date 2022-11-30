# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_variants
#
#  id                       :integer          not null, primary key
#  newsletter_experiment_id :integer          not null
#  variant_winner           :integer          default("not_winner"), not null
#  sections                 :jsonb
#  subject                  :string
#  status                   :integer          default("draft"), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_newsletter_variants_on_newsletter_experiment_id  (newsletter_experiment_id)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_experiment_id => newsletter_experiments.id)
#

class NewsletterVariant < ApplicationRecord
  belongs_to :newsletter_experiment
  has_many :events, class_name: 'NewsletterEvent', inverse_of: :newsletter_variant,
                    dependent: :destroy

  enum status: { draft: 0, sending: 1, sent: 2 }
  enum variant_winner: { not_winner: 0, subject: 1, content: 2, full: 3 }

  attribute :sections, Newsletter::SectionType.new

  delegate :newsletter, :sent?, to: :newsletter_experiment

  before_validation :normalize_subject

  def opened
    events.where(event_name: 'open').pluck('DISTINCT subscriber_id')
  end

  def delivered
    events.where(event_name: 'sent').pluck('DISTINCT subscriber_id')
  end

  def open_ratio
    delivered_count = delivered.count
    delivered_count == 0 ? 0 : (opened.count.to_f / delivered_count.to_f * 100.0).round(3)
  end

  private

  def normalize_subject
    self.subject = subject.strip unless subject.nil?
    self.subject = nil if subject.blank?
  end
end
