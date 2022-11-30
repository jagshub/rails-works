# frozen_string_literal: true

class Products::RefreshActivityEvents
  attr_reader :product

  def initialize(product)
    @product = product
  end

  def call
    HandleRaceCondition.call(transaction: true) do
      product.activity_events.destroy_all

      # Note(AR): Oldest to newest, so that posts could have sequential titles
      date_ordering = Arel.sql('COALESCE(posts.featured_at, posts.scheduled_at, posts.created_at) ASC')
      ordered_posts = product.featured_posts.order(date_ordering)

      ordered_posts.each do |post|
        create_post_event(post)

        Badges::TopPostBadge.where(subject: post).find_each do |badge|
          create_top_post_badge_event(badge)
        end

        Badges::GoldenKittyAwardBadge.where(subject: post).find_each do |badge|
          create_golden_kitty_badge_event(badge)
        end
      end

      product.story_mentions.find_each do |story|
        create_story_event(story)
      end
    end
  end

  def create_post_event(post)
    product.activity_events.create!(subject: post, occurred_at: post.date)
  end

  def create_top_post_badge_event(badge)
    if badge.period == 'daily' && badge.date == Time.current.to_date
      # Note(AR): The day isn't over, so we don't create an event for it yet,
      # since the subject will change throughout the day.
      return
    end

    date =
      case badge.period
      when 'daily' then badge.date
      when 'weekly'
        # Note(AR): End of the week starting Sunday -- last Saturday
        badge.date.end_of_week(:sunday)
      when 'monthly' then badge.date.end_of_month
      else raise "Unknown time period: #{ badge.period }"
      end

    votes_count = badge.subject.votes.where('DATE(created_at) <= ?', date).count
    comments_count = badge.subject.comments.where('DATE(created_at) <= ?', date).count

    product.activity_events.create!(
      subject_id: badge.id,
      subject_type: badge.type,
      occurred_at: date,
      votes_count: votes_count,
      comments_count: comments_count,
    )
  end

  def create_golden_kitty_badge_event(badge)
    nominations_count =
      GoldenKitty::Nominee
      .joins(golden_kitty_category: :edition)
      .merge(GoldenKitty::Edition.where(year: badge.year))
      .count

    product.activity_events.create!(
      subject_id: badge.id,
      subject_type: badge.type,
      occurred_at: badge.created_at,
      nominations_count: nominations_count,
    )
  end

  def create_story_event(story)
    product.activity_events.create!(subject: story, occurred_at: story.created_at)
  end
end
