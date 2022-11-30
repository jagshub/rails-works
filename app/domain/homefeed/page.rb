# frozen_string_literal: true

class Homefeed::Page
  attr_reader :page, :cursor, :items, :kind, :title, :subtitle, :hide_after, :date

  def initialize(page:, cursor:, items:, kind:, title: nil, subtitle: nil, hide_after: nil, next_page: nil, date: nil)
    @page = page
    @cursor = cursor
    @items = items
    @kind = kind
    @title = title
    @subtitle = subtitle
    @hide_after = hide_after
    @next_page = next_page
    @date = date
  end

  def id
    "#{ kind }-#{ cursor }"
  end

  def previous_page?
    page.positive?
  end

  FIRST_POST_DATE = Date.new(2013, 11, 27)

  def next_page?
    return @next_page if @next_page.in? [true, false]

    # NOTE(rstankov): In test ENV, often no post are available, so we skip next page if this is the case
    return false if Rails.env.test? && Post.for_scheduled_date((page + 1).days.ago.to_date).none?

    page < (Time.zone.today - FIRST_POST_DATE).to_i
  end

  # NOTE(DZ): For now, only fetch 3 within 7 days
  COMING_SOON_DAYS = 7
  COMING_SOON_LIMIT = 3
  def coming_soon
    return [] if page > 1

    Upcoming::Event
      .visible
      .by_closest_schedule
      .within_days(COMING_SOON_DAYS)
      .limit(COMING_SOON_LIMIT)
      .to_a
  end
end
