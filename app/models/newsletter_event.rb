# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_events
#
#  id                    :integer          not null, primary key
#  event_name            :string           not null
#  time                  :datetime         not null
#  subscriber_id         :integer
#  newsletter_id         :integer
#  link_url              :string
#  ip                    :string
#  geo                   :string
#  agent                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  newsletter_variant_id :integer
#  link_section          :string
#
# Indexes
#
#  index_newsletter_events_on_newsletter_id_and_event_name  (newsletter_id,event_name)
#  index_newsletter_events_on_newsletter_variant_id         (newsletter_variant_id)
#  index_newsletter_events_on_subscriber_id                 (subscriber_id)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_id => newsletters.id)
#  fk_rails_...  (newsletter_variant_id => newsletter_variants.id)
#  fk_rails_...  (subscriber_id => notifications_subscribers.id)
#

class NewsletterEvent < ApplicationRecord
  belongs_to :newsletter, inverse_of: :events, optional: true
  belongs_to :subscriber, inverse_of: :newsletter_events, optional: true
  belongs_to :newsletter_variant, inverse_of: :events, optional: true
end
