# frozen_string_literal: true

ActiveAdmin.register OAuth::Application do
  menu label: 'Oauth Apps', parent: 'Others'

  config.per_page = 20

  permit_params :owner_id, :name, :redirect_uri, :owner_type, :write_access_allowed,
                :twitter_app_name, :twitter_auth_allowed, :max_requests_per_hour, :max_points_per_hour,
                :twitter_consumer_key, :twitter_consumer_secret, :verified, :legacy

  filter :id
  filter :name, as: :string
  filter :owner_id
  filter :redirect_uri, as: :string
  filter :uid, as: :string
  filter :legacy, as: :boolean
  filter :write_access_allowed, as: :boolean
  filter :verified, as: :boolean

  scope(:v2, default: true, &:not_legacy)
  scope(:all, &:all)
  scope(:recently_active) { |scope| scope.not_legacy.joins(:requests).where(OAuth::Request.arel_table[:last_request_at].gt(5.hours.ago)) }
  scope(:legacy_recently_active) { |scope| scope.legacy.where(id: ::RateLimiter::API.app_ids) }

  index do
    column :id
    column :name
    column :owner do |app|
      "#{ app.owner.name }(#{ app.owner_id })" if app.owner.present? && app.owner.name.present?
    end

    if params['scope'] == 'recently_active'
      column :points_remaining do |app|
        app.rate_limiter_graphql.remaining
      end
      column :points_limit do |app|
        app.rate_limiter_graphql.limit
      end
      column :last_limit_reset_at do |app|
        app.rate_limiter_graphql.last_reset_at
      end
      column :until_limit_reset do |app|
        app.rate_limiter_graphql.seconds_until_reset
      end
    elsif params['scope'] == 'legacy_recently_active'
      column :points_remaining do |app|
        app.rate_limiter.remaining
      end
      column :points_limit do |app|
        app.rate_limiter.limit
      end
      column :last_limit_reset_at do |app|
        app.rate_limiter.last_reset_at
      end
      column :until_limit_reset do |app|
        app.rate_limiter.seconds_until_reset
      end
    else
      column :redirect_uri do |app|
        app.redirect_uri.truncate(40)
      end
      column :write_access_allowed
      column :verified
    end

    column :max_requests_per_hour
    column :max_points_per_hour

    column :issued_tokens do |app|
      app.access_tokens.count
    end
    column :created_at
    actions
  end

  show do
    default_main_content

    panel 'Rate limiter' do
      attributes_table_for(oauth_application.rate_limiter) do
        row :request_allowed?
        row :limit
        row :remaining
        row :last_reset_at
        row :seconds_until_reset
      end
    end

    active_admin_comments
  end

  form do |f|
    if f.object.errors.any?
      f.inputs 'Errors' do
        f.object.errors.full_messages.join('|')
      end
    end
    f.inputs 'Details' do
      f.input :name
      f.input :redirect_uri, as: :string, placeholder: 'urn:ietf:wg:oauth:2.0:oob'
      f.input :owner_id, as: :reference
      f.input :owner_type, as: :hidden, input_html: { value: 'User' }
      f.input :verified, hint: 'Whether the app has been verified by Product Hunt.'
      f.input :legacy, hint: 'Whether the app was created via V1 API.'
      f.input :write_access_allowed
      f.input :max_points_per_hour, hint: 'The hour value is split equally into 15mins slots. Set to 0 for infinite'
      f.input :twitter_app_name
      f.input :twitter_auth_allowed
      f.input :twitter_consumer_key
      f.input :twitter_consumer_secret
      f.input :max_requests_per_hour, hint: '(Legacy setting for V1 API) The hour value is split equally into 15mins slots. Set to 0 for infinite'
    end
    f.actions
  end
end
