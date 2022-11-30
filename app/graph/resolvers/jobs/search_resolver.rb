# frozen_string_literal: true

class Graph::Resolvers::Jobs::SearchResolver < Graph::Resolvers::BaseSearch
  scope { Job.published }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'JobOrder'

    value 'RECENT'
    value 'RENEWAL'
    value 'FEATURED'
  end

  class KindType < Graph::Types::BaseEnum
    graphql_name 'Kind'

    value 'ALL'
    value 'INHOUSE'
    value 'ANGELLIST'
  end

  option(:order, type: OrderType, default: 'RECENT')
  option(:kind, type: KindType, default: 'ALL')
  option(:query, type: String) { |scope, value| value.present? && scope.where('company_name ILIKE :term or job_title ILIKE :term or company_tagline ILIKE :term', term: LikeMatch.by_words(value)) }
  option(:remote_ok, type: Boolean) { |scope, value| value.present? && (value == true) && scope.where(remote_ok: value) }
  option(:locations, type: [String]) { |scope, value| value.present? && value.any? && scope.where("data->'locations' ?| array[:test]", test: value) }
  option(:categories, type: [String]) { |scope, value| value.present? && value.any? && scope.where("data->'categories' ?| array[:test]", test: value) }
  option(:roles, type: [String]) { |scope, value| value.present? && value.any? && scope.where("data->'roles' ?| array[:test]", test: value) }
  option(:skills, type: [String]) { |scope, value| value.present? && value.any? && scope.where("data->'skills' ?| array[:test]", test: value) }
  option(:featured_in_homepage, type: Boolean) { |scope, value| value ? scope.featured_in_homepage : scope.not_featured_in_homepage }

  private

  def apply_order_with_recent(scope)
    scope.order(external_created_at: :desc)
  end

  def apply_order_with_renewal(scope)
    scope.order('last_payment_at DESC NULLS LAST')
  end

  def apply_order_with_featured(scope)
    scope.featured_in_homepage_order
  end

  def apply_kind_with_all(scope)
    scope
  end

  def apply_kind_with_inhouse(scope)
    scope.inhouse
  end

  def apply_kind_with_angellist(scope)
    scope.angellist
  end
end
