# frozen_string_literal: true

module Sharing::Text::BadgesTopPostBadge
  extend self

  def call(badge)
    post = badge.subject

    "#{ post.name } is the ##{ badge.position } Product of the #{ period_for(badge) } on @ProductHunt for #{ subtitle(badge) } #{ Routes.post_url(post) }"
  end

  private

  def period_for(badge)
    if badge.period == 'weekly'
      'Week'
    elsif badge.period == 'monthly'
      'Month'
    else
      'Day'
    end
  end

  def subtitle(badge)
    return 'Today' if badge.period == 'daily' && badge.date.today?

    format = badge.period == 'monthly' ? '%B %Y' : '%B %d, %Y'

    badge.date.strftime(format)
  end
end
