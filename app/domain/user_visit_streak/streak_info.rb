# frozen_string_literal: true

EMOJIS = [
  nil,
  nil,
  '☀️',
  '✨',
  '⚡️',
  '🌟',
  '🎉',
  '🔥',
  '🍿',
  '🦄',
  '👑',
  '👏',
  '🥳',
  '😻',
  '🤘',
  '🧡',
  '🎤',
  '🍭',
  '🍩',
  '🌼',
  '🐝',
  '🎂',
  '💥',
  '🔮',
  '💎',
  '🚀',
  '🚨',
  '🦾',
  '🙀',
  '🤯',
  '🏆',
].freeze

class UserVisitStreak::StreakInfo
  attr_reader :duration

  def initialize(duration)
    @duration = duration
  end

  def emoji
    @emoji ||= emoji_for_duration
  end

  def text
    @text ||= text_for_duration
  end

  private

  def emoji_for_duration
    duration >= EMOJIS.length ? '🔥' : EMOJIS[duration]
  end

  def text_for_duration
    texts = [
      'Streaker alert! Discover something awesome today.',
      'Streaking looks good on you. Keep it up.',
      "That's it. Get your streak on.",
      'Crushin\' it. Thanks for being part of this community.',
    ]

    case duration
    when 0..1
      nil
    when 2..8 # Text changes every day
      streak_day = duration - 2 # Start with texts[0] for day 2
      texts[streak_day % texts.length]
    else # Text changes every week
      week = ((duration - 9) / 7).floor # Count weeks from day 9 onwards
      offset_week = week + 3 # Start with texts[3] for the week of day 9, because day 8 uses texts[2]
      texts[offset_week % texts.length]
    end
  end
end
