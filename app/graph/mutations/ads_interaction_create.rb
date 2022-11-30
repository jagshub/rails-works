# frozen_string_literal: true

module Graph::Mutations
  class AdsInteractionCreate < BaseMutation
    class AdsInteractionEnumType < Graph::Types::BaseEnum
      value 'impression', 'An impression event'
    end

    class AdsInteractionReferenceType < Graph::Types::BaseEnum
      Ads::Interaction::WEB_REFERENCES.each do |k, v|
        value k, v
      end
    end

    argument :attribution_id, ID, required: true
    argument :interaction, AdsInteractionEnumType, required: true
    argument :reference, AdsInteractionReferenceType, required: false

    def perform(inputs)
      channel = Ads::Channel.find(inputs[:attribution_id])

      cookies = context[:cookies]
      Ads.trigger_interaction(
        channel: channel,
        user: current_user,
        kind: inputs[:interaction],
        reference: inputs[:reference] || 'unknown',
        track_code: cookies[:track_code],
        request: context[:request],
      )

      nil
    end
  end
end
