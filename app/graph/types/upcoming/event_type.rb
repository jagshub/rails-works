# frozen_string_literal: true

module Graph::Types
  class Upcoming::EventType < BaseNode
    implements SeoInterfaceType
    implements SubscribableInterfaceType
    implements Graph::Types::ShareableInterfaceType

    graphql_name 'UpcomingEvent'

    association :product, ProductType, null: false
    association :post, PostType, null: true
    association :user, UserType, null: false

    field :title, String, null: false
    field :description, String, null: false
    field :banner_uuid, String, null: false
    field :banner_mobile_uuid, String, null: true
    field :active, Boolean, null: false
    field :approved, Boolean, null: false, method: :approved?
    field :can_edit, resolver: Graph::Resolvers::Can.build(:edit)
    field :url, String, null: false

    def url
      Routes.product_url(object.product)
    end

    field :last_moderated_at, DateTimeType, null: true
    field :last_moderated_by, UserType, null: true
    field :user_edited_at, DateTimeType, null: true

    def last_moderated_at
      return unless ApplicationPolicy.can?(context[:current_user], :moderate, object)

      object.moderation_logs.maximum(:created_at)
    end

    def last_moderated_by
      return unless ApplicationPolicy.can?(context[:current_user], :moderate, object)

      object.moderation_logs.order(:created_at).last&.moderator
    end

    def user_edited_at
      return unless ApplicationPolicy.can?(context[:current_user], :moderate, object)

      object.user_edited_at.presence
    end

    # NOTE(DZ): N+1
    field :is_first_launch, Boolean, null: false, method: :first_launch?
  end
end
