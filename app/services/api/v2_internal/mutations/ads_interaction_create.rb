# frozen_string_literal: true

module API::V2Internal::Mutations
  class AdsInteractionCreate < BaseMutation
    class AdsInteractionEnumType < API::V2Internal::Types::BaseEnum
      value 'close', 'A close event'
      value 'impression', 'An impression event'
    end

    argument :attributionId, GraphQL::Types::ID, required: true
    argument :interaction, AdsInteractionEnumType, required: true
    argument :reference, String, required: false

    def perform
      channel = Ads::Channel.find(inputs[:attributionId])
      reference = Ads.validate_reference(inputs[:reference])

      Ads.trigger_interaction(
        channel: channel,
        user: current_user,
        kind: inputs[:interaction],
        reference: reference,
        track_code: nil,
        request: ctx[:request],
      )

      nil
    end
  end
end
