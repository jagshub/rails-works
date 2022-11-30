# frozen_string_literal: true

module API::V1::Sorting
  PER_PAGE_MAX_COUNT = 50

  module ClassMethods
    def sort_by(*attributes)
      config[:sort_whitelist] = hashify_all_sort_values attributes
    end

    def sort_whitelist
      config[:sort_whitelist] ||= []
    end

    private

    def hashify_all_sort_values(array)
      array.each_with_object({}) do |attr, hash|
        (key, value) = attr.is_a?(Hash) ? [attr.keys.first, attr.values.first] : [attr, attr]
        hash[key.to_s] = value.to_s
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  attr_reader :per_page, :paging

  def initialize(options = {})
    options = ActionController::Parameters.new(options) if options.is_a? Hash
    @paging = options.delete(:paging).permit(:sort_by, :order, :newer, :older, :page, :per_page)

    super options
  end

  def fetch_results
    apply_paging super
  end

  def sort_by_name_value
    sort_value_or_fallback(paging[:sort_by])
  end

  def sort_by_order_value
    order_value_or_fallback(paging[:order])
  end

  def per_page
    per_page = paging[:per_page].to_i.abs
    return PER_PAGE_MAX_COUNT if per_page.zero? || per_page > PER_PAGE_MAX_COUNT

    per_page
  end

  def ordering
    { sort_by_name_value => sort_by_order_value }
  end

  def page
    paging[:page].presence || 1
  end

  private

  # NOTE(andreasklinger): Not using search_objects `option()` b/c we need explicit ordering of the chain
  def apply_paging(scope)
    # NOTE(andreasklinger): Leaving explicit condition here to avoid any user confusion.
    #   Users are supposed to either use keyset pagination OR page offset
    if paging[:page].present?
      scope = scope.offset([page.to_i - 1, 0].max * per_page)
    else
      scope = scope.where(id: newer_model_ids(scope)) if paging[:newer].present?
      scope = scope.where(id: older_model_ids(scope)) if paging[:older].present?
    end

    scope
      .limit(per_page)
      .order(ordering)
      .where.not(sort_by_name_value => nil) # used to avoid troubles w/ nil values (eg. featured_at)
  end

  def newer_model_ids(scope)
    scope.limit(per_page).where(scope.arel_table[:id].gt(paging[:newer])).order(id: :asc).pluck(:id)
  end

  def older_model_ids(scope)
    scope.limit(per_page).where(scope.arel_table[:id].lt(paging[:older])).order(id: :desc).pluck(:id)
  end

  def sort_value_or_fallback(name)
    @sort_value_or_fallback ||= self.class.sort_whitelist.key?(name.to_s) ? self.class.sort_whitelist[name.to_s] : self.class.sort_whitelist.values.first.to_s
  end

  def order_value_or_fallback(name)
    @order_value_or_fallback ||= ['desc', 'asc'].include?(name.to_s) ? name.to_s : 'desc'
  end
end
