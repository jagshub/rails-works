# frozen_string_literal: true

module Subscribeable
  extend ActiveSupport::Concern

  included do
    # TODO(DZ): Default name should be reserved to associations without scope.
    # This association pair should be named `subscriptions` and `active_subscriptions`.
    # Doing so, the counter cache columnn `followers_count` should also be updated to
    # reflect the number of active subscriptions (topics table). Graph fields should
    # be resolved by `active_` methods, avoiding renaming the client.
    has_many :all_subscriptions, class_name: '::Subscription', as: :subject, dependent: :delete_all, inverse_of: :subject

    has_many :subscriptions, -> { active }, as: :subject, inverse_of: :subject
    has_many :subscribers, through: :subscriptions
    has_many :followers, through: :subscribers, source: :user
  end
end
