# frozen_string_literal: true

ActiveAdmin.register Subscriber, as: 'NewsletterSubscribers' do
  menu label: 'Subscribers', parent: 'Newsletters'
  config.sort_order = 'created_at_desc'
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  actions :all, except: %i(new create show)

  permit_params :email, :newsletter_subscription

  filter :email, as: :string
  filter :user_username, as: :string

  scope(:all, default: true) do |scope|
    scope.includes(:user).where('email IS NOT NULL OR user_id IS NOT NULL')
  end

  index do
    column :email, as: :email
    column :subscribed do |subscriber|
      status_tag(subscriber.subscribed_to_newsletter? ? 'Yes' : 'No')
    end
    column :type do |subscriber|
      subscriber.newsletter_subscription if subscriber.subscribed_to_newsletter?
    end
    column :user do |subscriber|
      link_to '@' + subscriber.user.username, admin_user_path(subscriber.user) if subscriber.user.present?
    end
    column :created_at
    column 'Edit' do |collection|
      link_to 'Edit', edit_admin_newsletter_subscriber_path(collection.id)
    end
    column 'Delete' do |collection|
      link_to 'Delete', admin_newsletter_subscriber_path(collection.id), data: { method: :delete, confirm: 'Are you sure you want to delete this?' }
    end
  end

  form do |f|
    f.inputs 'Newsletter Subscriber' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :email, as: :string
      f.input :newsletter_subscription, as: :select, collection: Newsletter::Subscriptions::STATES, include_blank: false
    end
    f.actions
  end
end
