# frozen_string_literal: true

ActiveAdmin.register User, as: 'Founder Club Member' do
  menu label: 'Members', parent: 'Founder Club'

  actions :index

  scope('Active') { |scope| scope.merge(Payment::Subscription.active) }
  scope('Expired') { |scope| scope.merge(Payment::Subscription.expired) }
  scope('Canceled') { |scope| scope.merge(Payment::Subscription.canceled) }
  scope('Not Canceled') { |scope| scope.merge(Payment::Subscription.not_canceled) }
  scope('Refunded') { |scope| scope.merge(Payment::Subscription.refunded) }

  controller do
    def scoped_collection
      User.joins(:payment_subscriptions).merge(Payment::Subscription.from_project('founder_club').reverse_chronological)
    end
  end

  config.per_page = 20
  config.paginate = true

  filter :username
  filter :name
  filter :subscriber_email, as: :string, label: 'User Email'

  index pagination_total: false do
    selectable_column
    column :id
    column :name do |user|
      formatted_user_name(user)
    end
    column :username
    column :email
    column :role do |user|
      formatted_user_role(user)
    end

    column :subscription do |user|
      subscription = user.payment_subscriptions.find_by_project('founder_club')
      link_to payment_subscription_status(subscription), External::StripeApi.subscription_url(subscription.stripe_subscription_id), target: '_blank', rel: 'noopener'
    end
    column :charged_amount do |user|
      subscription = user.payment_subscriptions.find_by_project('founder_club')
      "$#{ subscription.charged_amount_in_cents / 100 }"
    end
  end
end
