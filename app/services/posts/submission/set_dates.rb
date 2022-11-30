# frozen_string_literal: true

class Posts::Submission::SetDates
  NOW = 'now'

  MAX_DAILY_FEATURED_POSTS_PER_USER = 2
  MAX_DAILY_SCHEDULED_POSTS_PER_USER = 2

  def self.call(post:, user:, featured_at:)
    new(post, user).call(featured_at)
    post
  end

  def initialize(post, user)
    @user = user
    @post = post
  end

  def call(input_date)
    return unless can_set_date?(input_date)

    datetime = proper_date(input_date)
    check_date_maximum_errors(datetime)

    post.featured_at = datetime if can_feature?(datetime)
    post.scheduled_at = datetime
  end

  private

  attr_reader :post, :user

  # NOTE(DZ): We don't show error message for featured_at exceeding maximum
  # right now. Current behaviour is to quietly unset featured_at field. If we
  # change this, ideally it goes here instead of #can_feature?
  def check_date_maximum_errors(input_date)
    date = proper_date(input_date).to_date

    return if does_not_exceed_schedule_maximum?(date)

    post.errors.add :scheduled_at, "You have scheduled the maximum amount of posts for #{ date }"
    raise ActiveRecord::RecordInvalid, post
  end

  def can_set_date?(input_date)
    return true if post.new_record?
    return true if input_date.present? && (post.scheduled_at.future? || post.featured_at&.future?)

    false
  end

  def can_feature?(date)
    # NOTE(rstankov): Admins can feature more than once per day
    return true if user.admin?

    # NOTE(emilov) might not be allowed to feature BUT allow here, if post is already featured
    return true if post.featured_at.present?

    # NOTE(emilov) not allowed to feature AND not featured already
    return false unless ApplicationPolicy.can?(user, :feature, post)

    post.user.posts.for_featured_date(date.to_date).count < MAX_DAILY_FEATURED_POSTS_PER_USER
  end

  def proper_date(input)
    ProperDate.call(
      input: input,
      min_date: post.created_at || Time.current,
      max_days: max_schedule_days,
    )
  end

  def max_schedule_days
    32.days
  end

  def does_not_exceed_schedule_maximum?(date)
    post.user.posts.where.not(id: post.id)
        .for_scheduled_date(date).count < MAX_DAILY_SCHEDULED_POSTS_PER_USER
  end

  module ProperDate
    extend self

    def call(input:, min_date:, max_days:)
      time = parse_date(input) || min_date
      time = [time, min_date].max
      [time, min_date + max_days].min
    end

    private

    def parse_date(date)
      return if date.blank?

      date = Time.current if date == NOW
      date = Time.zone.parse(date) unless date.is_a?(ActiveSupport::TimeWithZone)
      date
    rescue ArgumentError
      nil
    end
  end
end
