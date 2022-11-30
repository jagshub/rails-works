# frozen_string_literal: true

# Note (LukasFittl): Check whether the user actually clicked through to the product.

module SpamChecks::Filters::CustomVoteFilter::NoClickThrough
  extend self

  def spam_score(_vote)
    :skip
  end

  def vote_ring_score(vote)
    :problematic unless user_clicked_on_post?(vote) || api_vote?(vote)
  end

  def user_clicked_on_post?(vote)
    return true unless vote.subject_type == 'Post'

    vote.subject.link_trackers.where(user_id: vote.user_id).any?
  end

  # Note (LukasFittl): API click throughs are often made without an active logged-in session,
  #   therefore we can't use them effectively for this right now. This should probably
  #   be fixed by passing the current user to the click through link.
  def api_vote?(vote)
    info = vote.vote_info
    return false if info.blank?

    info.oauth_application.present?
  end
end
