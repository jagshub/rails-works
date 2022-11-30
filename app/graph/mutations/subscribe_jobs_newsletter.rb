# frozen_string_literal: true

module Graph::Mutations
  class SubscribeJobsNewsletter < BaseMutation
    SUCCESS = OpenStruct.new(is_subscribed: true)

    argument :email, String, required: false
    argument :locations, [String], required: false
    argument :roles, [String], required: false
    argument :skills, [String], required: false

    returns Graph::Types::EmailDigestType

    def perform(email: nil, locations: nil, roles: nil, skills: nil)
      subscriber =
        Subscribers.register_and_verify(
          email: email,
          user: current_user,
        )

      return error :subscriber, :blank if subscriber.nil?

      subscriber.jobs_newsletter_subscription = Jobs::Newsletter::Subscriptions::SUBSCRIBED
      subscriber.jobs_newsletter_subscription_locations = locations if locations.present?
      subscriber.jobs_newsletter_subscription_roles = roles if roles.present?
      subscriber.jobs_newsletter_subscription_skills = skills if skills.present?
      subscriber.save!

      return errors_from_record(subscriber) if subscriber.errors.present?

      success SUCCESS
    end
  end
end
