# frozen_string_literal: true

module GoldenKitty::Nominations
  extend self

  def total_categories(edition)
    edition.phase == :nomination_started ? category_scope(edition).count.keys.length : 0
  end

  def first_category(edition:, user: nil)
    return if edition.phase != :nomination_started
    return category_scope(edition).first if user.blank?

    nominated = GoldenKitty::Category
                .joins(:nominees)
                .where('golden_kitty_nominees.user_id = ?', user.id)
                .pluck(:id)

    category = category_scope(edition)
               .where
               .not(id: nominated)
               .first

    return category_scope(edition).first if category.blank?

    category
  end

  def for_category_by_user(category:, user:)
    category.nominees.where(user: user)
  end

  def next_category(category)
    return if category.phase != :nomination

    categories = category_scope(category.edition)

    current_index = categories.pluck(:id).index(category.id) || 0

    categories[(current_index + 1)]
  end

  def prev_category(category)
    return if category.phase != :nomination

    categories = category_scope(category.edition)

    current_index = categories.pluck(:id).index(category.id) || 0

    return if current_index == 0

    categories[(current_index - 1)]
  end

  def category_index(category)
    return 1 if category.phase != :nomination

    (category_scope(category.edition).pluck(:id).index(category.id) || 0) + 1
  end

  def category_suggestions_for_user(category:, user: nil)
    return [] if category.phase != :nomination

    year = category.edition.year

    scope = Post
            .visible
            .between_dates(start_of_year(year), end_of_year(year))
            .where('posts.featured_at IS NOT NULL')

    scope = scope.in_topic(category.topic_id) if category.topic_id.present?

    if user.present?
      nominated = GoldenKitty::Nominee.where(golden_kitty_category_id: category.id, user_id: user.id).pluck(:post_id)
      scope = scope
              .joins("LEFT JOIN votes on posts.id = votes.subject_id AND votes.subject_type = 'Post' AND votes.user_id = #{ user.id }")
              .where.not(posts: { id: nominated })
              .group('posts.id')
              .order(Arel.sql('COUNT(votes.id) DESC'))
    end

    scope.order('posts.credible_votes_count DESC, posts.featured_at DESC')
  end

  private

  def category_scope(edition)
    edition
      .categories
      .joins('left join golden_kitty_people on golden_kitty_categories.id = golden_kitty_people.golden_kitty_category_id')
      .group('golden_kitty_categories.id')
      .having('count(golden_kitty_people.id) = 0')
      .by_priority
  end

  def start_of_year(year)
    Date.new(year).to_time.in_time_zone(Time.zone).beginning_of_day
  end

  def end_of_year(year)
    Date.new(year).end_of_year.to_time.in_time_zone(Time.zone).end_of_day
  end
end
