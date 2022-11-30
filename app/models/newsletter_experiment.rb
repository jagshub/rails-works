# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_experiments
#
#  id            :integer          not null, primary key
#  newsletter_id :integer          not null
#  status        :integer          default("draft"), not null
#  test_count    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_newsletter_experiments_on_newsletter_id  (newsletter_id)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_id => newsletters.id)
#

class NewsletterExperiment < ApplicationRecord
  belongs_to :newsletter, inverse_of: :experiment

  has_many :variants, class_name: 'NewsletterVariant', inverse_of: :newsletter_experiment, dependent: :destroy

  enum status: { draft: 0, sent: 1 }

  validates :test_count, presence: true, exclusion: { in: [0], message: "Test count can't be zero" }

  def sent?
    status == 'sent'
  end

  def sendable?
    variants.count > 1 && test_count % variants.count == 0 && newsletter.posts.any? && subjects?
  end

  def deliveries_count
    sent? ? NotificationLog.where(kind: :newsletter_experiment, notifyable_type: 'NewsletterVariant', notifyable_id: variant_ids).count : 0
  end

  private

  def subjects?
    variants.to_a.count { |variant| variant.subject.present? } != 1
  end
end
