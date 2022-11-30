# frozen_string_literal: true

module Graph::Types
  class SettingsType < BaseObject
    graphql_name 'Settings'

    field :beta_features, Boolean, null: false
    field :followed_topic_ids, [ID], null: false
    field :can_change_username, resolver: Graph::Resolvers::Can.build(:change_username, &:user)
    field :can_change_email, resolver: Graph::Resolvers::Can.build(:change_email, &:user)
    field :twitter_write_permission, Boolean, null: false
    field :user, UserType, null: false

    field :subscribed_products, ProductType.connection_type, null: false do
      argument :query, String, required: false
      argument :focus_id, ID, required: false, description: 'ID of the product to focus on'
    end

    def subscribed_products(query: nil, focus_id: nil)
      order =
        if focus_id.present?
          <<-SQL
            CASE WHEN products.id = ? THEN 1 ELSE 0 END desc,
            subscriptions.muted asc,
            subscriptions.created_at desc
          SQL
        else
          'muted asc, subscriptions.created_at desc'
        end

      scope =
        Product
        .joins(:subscriptions)
        .merge(object.user.subscriber.subscriptions.for_products)
        .order(ActiveRecord::Base.sanitize_sql_for_order([Arel.sql(order), focus_id]))

      return scope if query.blank?

      scope.where_like_slow(:name, query)
    end

    def beta_features
      ApplicationPolicy.can? object.user, :manage, :beta_features
    end

    def twitter_write_permission
      object.user.twitter_write_permission?
    end

    def followed_topic_ids
      object.user.followed_topic_ids
    end

    def crypto_wallet
      object.user.crypto_wallet&.address
    end

    delegate :user, to: :object

    SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
      name = attribute_name.to_s.gsub('_uid', '_connected')

      field name, Boolean, null: false

      define_method(name) do
        object.user[attribute_name].present?
      end
    end

    NOTIFICATION_OPTIONS = %i(hide_hiring_badge private_profile job_search remote
                              send_activity_browser_push send_activity_email
                              send_community_updates_email send_community_updates_browser_push
                              send_ph_updates_browser_push send_ph_updates_email
                              send_maker_updates_email send_ship_updates_email unsubscribe_from_all_notifications).freeze

    My::UserSettings.attribute_names.each do |name|
      if ::Notifications::UserPreferences::FLAGS.include?(name)
        field name, Boolean, null: false
      elsif NOTIFICATION_OPTIONS.include?(name)
        field name, Boolean, null: false
      elsif [:skills].include?(name)
        field name, [String], null: false
      else
        field name, String, null: true
      end
    end
  end
end
