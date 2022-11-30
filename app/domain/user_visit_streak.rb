# frozen_string_literal: true

module UserVisitStreak
  extend self

  def visit_streak_duration(user)
    return 0 unless user

    current_streak = user.visit_streaks.current.first

    return 0 if current_streak.blank?

    current_streak.duration
  end

  def current_streak_ends_in(user)
    current_streak = user.visit_streaks.current.first

    return if current_streak.blank?

    streak_ends_in(current_streak)
  end

  def mark_visit(user, platform: nil)
    return if user.nil?

    current_streak = user.visit_streaks.current.first

    if current_streak.blank?
      create_new_streak(user, platform)
    elsif should_reset_streak?(current_streak)
      end_current_streak(current_streak)
      create_new_streak(user, platform)
    else
      update_current_streak(current_streak, platform)
    end

    Iterable::SyncUserWorker.perform_later(user: user) ## Note(Bharat): sync user with iterable

    Iterable.trigger_event('mark_visit_streak', email: user.email, user_id: user.id)
  end

  def streak_info(user)
    return { duration: 0 } unless user

    current_streak = user.visit_streaks.current.first
    return { duration: 0 } if current_streak.blank?

    StreakInfo.new(current_streak.duration)
  end

  private

  def create_new_streak(user, platform)
    current_time = Time.current
    case platform
    when 'ios' then
      VisitStreak.create!(user: user, started_at: current_time, last_visit_at: current_time, last_ios_visit_at: current_time)
    when 'android' then
      VisitStreak.create!(user: user, started_at: current_time, last_visit_at: current_time, last_android_visit_at: current_time)
    when 'web' then
      VisitStreak.create!(user: user, started_at: current_time, last_visit_at: current_time, last_web_visit_at: current_time)
    else
      VisitStreak.create!(user: user, started_at: current_time, last_visit_at: current_time)
    end
  end

  def end_current_streak(current_streak)
    duration = (current_streak.last_visit_at.to_date - current_streak.started_at.to_date).to_i

    current_streak.update!(ended_at: current_streak.last_visit_at, duration: duration)
  end

  def update_current_streak(current_streak, platform)
    duration = (Time.zone.now.to_date - current_streak.started_at.to_date).to_i + 1

    current_time = Time.current
    case platform
    when 'ios' then
      current_streak.update!(duration: duration, last_visit_at: current_time, last_ios_visit_at: current_time)
    when 'android' then
      current_streak.update!(duration: duration, last_visit_at: current_time, last_android_visit_at: current_time)
    when 'web' then
      current_streak.update!(duration: duration, last_visit_at: current_time, last_web_visit_at: current_time)
    else
      current_streak.update!(duration: duration, last_visit_at: current_time)
    end
  end

  def should_reset_streak?(current_streak)
    time_since_last_visit(current_streak).round.to_i >= 48
  end

  def time_since_last_visit(current_streak)
    (Time.zone.now - current_streak.last_visit_at) / 1.hour
  end

  def streak_ends_in(streak)
    48 - time_since_last_visit(streak).round.to_i
  end
end
