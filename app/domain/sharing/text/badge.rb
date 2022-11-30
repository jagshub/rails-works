# frozen_string_literal: true

module Sharing::Text::Badge
  extend self

  def call(badge)
    post = badge.subject

    "#{ post.name } is the #{ title(badge) } on @ProductHunt for #{ subtitle(badge) } #{ Routes.post_url(post) }"
  end

  private

  def title(badge)
    case badge
    when Badges::GoldenKittyAwardBadge then badge.category
    when Badges::TopPostBadge then title_for_top_badge(badge)
    end
  end

  def subtitle(badge)
    case badge
    when Badges::GoldenKittyAwardBadge then "Golden Kitty #{ badge.year }"
    when Badges::TopPostBadge then subtitle_for_top_badge(badge)
    end
  end

  def title_for_top_badge(badge)
    period = if badge.period == 'weekly'
               'Week'

             elsif badge.period == 'monthly'
               'Month'
             else
               'Day'
             end

    "##{ badge.position } Product of the #{ period }"
  end

  def subtitle_for_top_badge(badge)
    return 'Today' if badge.period == 'daily' && badge.date.today?

    format = badge.period == 'monthly' ? '%B %Y' : '%B %d, %Y'

    badge.date.strftime(format)
  end
end
