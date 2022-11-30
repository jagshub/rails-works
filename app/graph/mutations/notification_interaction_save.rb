# frozen_string_literal: true

module Graph::Mutations
  class NotificationInteractionSave < BaseMutation
    ALLOWED_KEYS_IN_PAYLOAD = %i(id type url body).freeze
    ALLOWED_INTERACTIONS = %i(comment subscribe follow).freeze

    argument_record :feed_item, Stream::FeedItem, required: true, authorize: :update
    argument :interaction, String, required: true
    argument :payload, Graph::Types::JsonType, required: false

    returns Graph::Types::Notifications::FeedItemType

    def perform(feed_item:, interaction:, payload: nil)
      return error :base, :interaction_not_allowed unless ALLOWED_INTERACTIONS.include? interaction.to_sym

      payload = (payload || {}).slice(*ALLOWED_KEYS_IN_PAYLOAD).merge(occurred_at: Time.current)
      interaction_data = Hash[interaction.to_sym, payload]

      feed_item.update!(interactions: (feed_item.interactions || {}).merge(interaction_data))
      feed_item
    end
  end
end
