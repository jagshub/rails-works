# frozen_string_literal: true

module Graph::Mutations
  class AdsNewsletterOpen < BaseMutation
    argument :attributionId, ID, required: true

    def perform(inputs)
      newsletter = Ads::Newsletter.find inputs[:attributionId]
      Ads.trigger_newsletter_event subject: newsletter, event: 'open'

      nil
    end
  end
end
