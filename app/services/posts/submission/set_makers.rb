# frozen_string_literal: true

module Posts::Submission::SetMakers
  extend self

  def call(user:, post:, makers:)
    return if makers.nil?

    new_maker_usernames = Array(makers)
    old_maker_usernames = ::ProductMakers.makers_of(post: post).map(&:username)

    makers_to_add = new_maker_usernames - old_maker_usernames
    makers_to_add.each do |username|
      ::ProductMakers.add(
        by: user,
        maker: ::ProductMakers::Maker.new(username: username, post: post),
      )
    end

    makers_to_remove = old_maker_usernames - new_maker_usernames
    makers_to_remove.each do |username|
      ::ProductMakers.remove(
        by: user,
        maker: ::ProductMakers::Maker.new(username: username, post: post),
      )
    end
  end
end
