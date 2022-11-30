# frozen_string_literal: true

module Graph::Mutations
  class SubscriptionGoldenKittyCreate < BaseMutation
    argument_record :subject, GoldenKitty::Edition, required: true
    argument :email, String, required: true
    argument :newsletter_subscribe, Boolean, required: false

    returns Graph::Types::SubscribableInterfaceType

    def perform(subject:, email:, newsletter_subscribe:)
      return error :email, :invalid unless EmailValidator.valid?(email)

      subscriber =
        Subscribers.register_and_verify(
          email: email,
          user: current_user,
        )

      subscriber.update!(email_confirmed: true) if current_user.blank?

      ::Subscribe.subscribe(subject, nil, subscriber)

      if newsletter_subscribe
        Newsletter::Subscriptions.set(
          email: email,
          status: Newsletter::Subscriptions::DAILY,
          tracking_options: { source: "GoldenKittyEdition-#{ subject.id }" },
        )
      end

      subject
    end
  end
end
