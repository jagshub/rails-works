# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_newsletter_interactions
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)
#  kind         :string           not null
#  user_agent   :string
#  is_bot       :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_type :string
#  subject_id   :bigint(8)
#  ip_address   :string
#  visitor_id   :string
#
# Indexes
#
#  index_ads_newsletter_interactions_on_ads_newsletter_id  (ads_newsletter_id)
#  index_ads_newsletter_interactions_on_subject_columns    (subject_type,subject_id)
#  index_ads_newsletter_interactions_on_user_id            (user_id)
#
class Ads::NewsletterInteraction < ApplicationRecord
  self.ignored_columns = %w(ads_newsletter_id)

  include Namespaceable

  SUBJECTS = [Ads::Newsletter, Ads::NewsletterSponsor].freeze

  belongs_to :user, optional: true

  belongs_to_polymorphic :subject,
                         inverse_of: :interactions,
                         allowed_classes: SUBJECTS

  enum kind: { click: 'click', open: 'open' }, _prefix: true
end
