# frozen_string_literal: true

module ProductHunt
  extend self

  def user
    User.find_by_username(username)
  end

  def user!
    User.find_by_username!(username)
  end

  def username
    'producthunt'
  end
end
