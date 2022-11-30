# frozen_string_literal: true

Reviews::Scoring = Struct.new(:review) do
  MAX_POINTS = 900
  def score
    points = [
      upvotes,
      role,
      signup_date,
      body_length,
    ].sum

    [points, MAX_POINTS].min
  end

  private

  UPVOTES_MAX_POINTS = 400
  POINTS_PER_UPVOTE = 20
  def upvotes
    [(review.credible_votes_count * POINTS_PER_UPVOTE), UPVOTES_MAX_POINTS].min
  end

  ROLE_MAX_POINTS = 40
  ROLES = %i(can_post admin).freeze

  def role
    return ROLE_MAX_POINTS if ROLES.include?(review.user.role.to_sym)

    0
  end

  SIGNUP_DATE_MAX_POINTS = 100
  def signup_date
    return SIGNUP_DATE_MAX_POINTS if review.user.created_at < 24.hours.ago

    0
  end

  BODY_LENGTH_MAX_POINTS = 200
  def body_length
    body = review.comment&.body || ''
    return BODY_LENGTH_MAX_POINTS if body.length > 150

    0
  end
end
