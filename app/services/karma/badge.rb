# frozen_string_literal: true

class Karma::Badge
  KINDS = {
    balloon: 'BALLOON',
    plain: 'PLAIN',
    bronze: 'BRONZE',
    silver: 'SILVER',
    gold: 'GOLD',
  }.freeze

  POINTS_FOR_BADGES = {
    bronze: 100,
    silver: 500,
    gold: 1000,
  }.freeze

  MIN_USER_AGE_FOR_POINTS = 7.days.freeze

  def self.for(user)
    points = Karma.points_for_user(user)

    return new kind: KINDS[:balloon], score: 0 if user.created_at > MIN_USER_AGE_FOR_POINTS.ago
    return new kind: KINDS[:plain], score: points if points < POINTS_FOR_BADGES[:bronze]
    return new kind: KINDS[:bronze], score: points if points < POINTS_FOR_BADGES[:silver]
    return new kind: KINDS[:silver], score: points if points < POINTS_FOR_BADGES[:gold]

    new kind: KINDS[:gold], score: points
  end

  attr_reader :kind, :score

  def initialize(kind:, score:)
    @kind = kind
    @score = score
  end
end
