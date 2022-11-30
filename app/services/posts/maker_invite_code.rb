# frozen_string_literal: true

module Posts::MakerInviteCode
  extend self

  # NOTE(rstankov): This is a simple formula, I don't want to add extra fields to posts
  #  Goals is for invite maker codes to not be guessable.
  #  Pages are only active for a limited amount of time.
  #  - `created_at` should be immutable for post
  #  - a pair of slug and part of the code can give us enough security
  def code(post)
    Base64.encode64(post.created_at.to_i.to_s).delete('=').delete("\n").reverse[0..5]
  end

  def valid?(post, code)
    !post.locked? && code == code(post)
  end

  def path(post)
    Routes.post_maker_invite_path(post, code: code(post))
  end

  def url(post)
    Routes.post_maker_invite_url(post, code: code(post))
  end
end
