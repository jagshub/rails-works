# frozen_string_literal: true

module Mobile::Graph::Mutations
  class SettingsUpdate < BaseMutation
    argument :name, String, required: false
    argument :username, String, required: false
    argument :headline, String, required: false
    argument :about, String, required: false
    argument :links, [Graph::Types::UserLinkInputType], required: false
    argument :email, String, required: false
    argument :website_url, String, required: false
    argument :header_uuid, String, required: false
    argument :avatar, String, required: false
    argument :private_profile, Boolean, required: false
    argument :subscribe_daily_newsletter, Boolean, required: false
    argument :subscribe_jobs_newsletter, Boolean, required: false
    argument :subscribe_stories_newsletter, Boolean, required: false

    returns Mobile::Graph::Types::SettingsType

    require_current_user

    def perform(inputs)
      form = My::UserSettings.new(current_user)
      unless inputs[:subscribe_daily_newsletter].nil?
        inputs[:newsletter_subscription] =
          if inputs[:subscribe_daily_newsletter]
            Newsletter::Subscriptions::DAILY
          else
            Newsletter::Subscriptions::UNSUBSCRIBED
          end
      end
      unless inputs[:subscribe_jobs_newsletter].nil?
        inputs[:jobs_newsletter_subscription] =
          if inputs[:subscribe_jobs_newsletter]
            Jobs::Newsletter::Subscriptions::SUBSCRIBED
          else
            Jobs::Newsletter::Subscriptions::UNSUBSCRIBED
          end
      end
      unless inputs[:subscribe_stories_newsletter].nil?
        inputs[:stories_newsletter_subscription] =
          if inputs[:subscribe_stories_newsletter]
            Anthologies::Stories::Newsletter::Subscriptions::SUBSCRIBED
          else
            Anthologies::Stories::Newsletter::Subscriptions::UNSUBSCRIBED
          end
      end
      form.update(inputs)

      Iterable::SyncUserWorker.perform_later(user: current_user) ## Note(Bharat): sync user details with iterable
      Iterable::SyncUserSubscriptionWorker.perform_later(current_user) ## Note(Bharat): sync user subscriptions with iterable
      form
    end
  end
end
