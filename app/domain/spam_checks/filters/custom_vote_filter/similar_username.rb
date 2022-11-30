# frozen_string_literal: true

module SpamChecks::Filters::CustomVoteFilter::SimilarUsername
  extend self

  def spam_score(_vote)
    :skip
  end

  def vote_ring_score(vote)
    return :problematic if similar_username_exist?(vote.user.username)

    false
  end

  private

  def similar_username_exist?(username)
    return false if username.start_with? 'deleted-'
    return false if username.start_with? 'new_user_'

    # NOTE(naman): this returns digits from the end
    number = username.gsub(/^[^\d]*\d*[^\d]*/, '')
    return false unless number.length >= 3

    base = username[0...(username.length - number.length)]
    username_pattern = base + '(0|1|2|3|4|5|6|7|8|9)' * number.length

    return true if User.where('username similar to ?', username_pattern).count > 3

    false
  end
end
