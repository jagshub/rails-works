# frozen_string_literal: true

module Featurable
  def featured?
    featured_at.present? && featured_at <= Time.current
  end

  def unfeature
    update! featured_at: nil
  end

  def feature
    update! featured_at: Time.current
  end

  def schedule(time)
    update! featured_at: time
  end
end
