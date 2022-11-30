# frozen_string_literal: true

module Graph::Types
  class PostSubmissionMakerType < BaseObject
    field :id, ID, null: true
    field :username, String, null: false
    field :name, String, null: true

    def id
      object.user&.id
    end

    def name
      object.user&.name
    end
  end

  class PostSubmissionType < BaseObject
    field :url, String, null: false
    field :additional_links, [String], null: false
    field :makers, [PostSubmissionMakerType], null: false
    field :multiplier, Float, null: false
    field :created_at, DateTimeType, null: false
    field :post_text, String, null: false
    field :post_code, String, null: false
    field :post_expire_at, DateTimeType, null: false

    def additional_links
      object.links.not_primary.map(&:url)
    end

    def makers
      ProductMakers.makers_of(post: object)
    end

    def multiplier
      return 1 unless ApplicationPolicy.can?(context[:current_user], :moderate, object)

      object.score_multiplier
    end
  end
end
