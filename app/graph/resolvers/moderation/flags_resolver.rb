# frozen_string_literal: true

class Graph::Resolvers::Moderation::FlagsResolver < Graph::Resolvers::BaseSearch
  type Graph::Types::FlagType.connection_type, null: false

  scope { Flag.unresolved }

  class SubjectType < Graph::Types::BaseEnum
    graphql_name 'ModerationFlagSubject'

    Flag.subject_types.each do |subject|
      value subject.model_name.name.gsub('::', '')
    end
  end

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'ModerationFlagFilter'

    value 'urgent', 'Harmful or spam flags'
    value 'other', 'Everything else'
  end

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ModerationFlagOrder'

    value 'latest', 'Sort by the newest flags'
    value 'frequent', 'Sort by the highest number of flags'
  end

  option :subject, type: SubjectType, default: 'Comment'
  option :filter, type: FilterType, default: 'urgent'
  option :order, type: OrderType, default: 'latest'

  private

  def apply_subject_with_comment(scope)
    scope.where(subject_type: 'Comment')
  end

  def apply_subject_with_review(scope)
    scope.where(subject_type: 'Review')
  end

  def apply_subject_with_post(scope)
    scope.where(subject_type: 'Post')
  end

  def apply_subject_with_product_request(scope)
    scope.where(subject_type: 'ProductRequest')
  end

  def apply_subject_with_recommendation(scope)
    scope.where(subject_type: 'Recommendation')
  end

  def apply_subject_with_user(scope)
    scope.where(subject_type: 'User')
  end

  def apply_subject_with_product(scope)
    scope.where(subject_type: 'Product')
  end

  def apply_subject_with_team_invite(scope)
    scope.where(subject_type: 'Team::Invite')
  end

  def apply_subject_with_team_request(scope)
    scope.where(subject_type: 'Team::Request')
  end

  def apply_filter_with_urgent(scope)
    scope.urgent
  end

  def apply_filter_with_other(scope)
    scope.other
  end

  def apply_order_with_latest(scope)
    scope.order(created_at: :desc)
  end

  def apply_order_with_frequent(scope)
    scope.order(other_flags_count: :desc)
  end
end
