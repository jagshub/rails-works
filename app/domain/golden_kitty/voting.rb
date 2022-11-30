# frozen_string_literal: true

class GoldenKitty::Voting
  def initialize(category:, user: nil)
    @category = category
    @current_user = user
    @edition = category.edition
  end

  def enabled?
    phase == :voting
  end

  def prev_category
    return if index < 1

    categories[index - 1]
  end

  def next_category
    return if index == categories.length - 1

    categories[index + 1]
  end

  def finalists
    @finalists ||= @category.finalists.by_random
  end

  def people
    @poeple ||= finalists.empty? ? @category.people.joins(:user).by_random.map(&:user) : []
  end

  def kind
    @kind ||= finalists.empty? ? 'PERSON' : 'PRODUCT'
  end

  private

  def phase
    @phase ||= @category.phase(@current_user)
  end

  def categories
    @categories ||= GoldenKitty::Voting.available_categories(edition: @edition, user: @current_user)
  end

  def index
    @index ||= categories.pluck(:id).index(@category.id)
  end

  class << self
    def first_available_category(edition:, user: nil)
      scope = available_categories(edition: edition, user: user)

      return scope.first if user.blank? || scope.empty?

      category = scope
                 .joins(ExecSql.sanitize_sql("LEFT JOIN ( golden_kitty_finalists AS f INNER JOIN votes AS v ON v.subject_id = f.id AND v.subject_type = 'GoldenKitty::Finalist' AND v.user_id = :user_id) ON f.golden_kitty_category_id = golden_kitty_categories.id", user_id: user.id))
                 .group('golden_kitty_categories.id')
                 .having('count(f.id) = 0')

      category.first || scope.first
    end

    def available_categories(edition:, user: nil)
      return [] if edition.phase(nil, user) != :voting_started

      scope = edition
              .categories
              .where('voting_enabled_at IS NOT NULL AND voting_enabled_at <= ?', Time.zone.now)

      scope = scope.or(edition.categories.where(id: available_category_ids_for_beta_users(edition))) if beta_user?(user)

      scope.order('voting_enabled_at ASC, priority DESC')
    end

    def available_category_ids_for_beta_users(edition)
      setting = Setting.where(name: "gk_#{ edition.year }_open_voting_for_categories").first
      return [] if setting.blank?

      setting.value.split(',').map(&:to_i)
    end

    def beta_user?(user = nil)
      user.present? && Features.enabled?(:ph_gk_voting_phase, user)
    end
  end
end
