# frozen_string_literal: true

module Graph::Mutations
  class StoryNewsletterSubscriptionCreate < BaseMutation
    SUCCESS = OpenStruct.new(is_subscribed: true)

    argument :email, String, required: false

    returns Graph::Types::EmailDigestType

    def perform(email: nil)
      result = Anthologies::Stories::Newsletter::Subscriptions.set(
        email: email,
        user: current_user,
        status: Anthologies::Stories::Newsletter::Subscriptions::SUBSCRIBED,
      )

      return error :subscriber, :blank unless result

      success SUCCESS
    end
  end
end
