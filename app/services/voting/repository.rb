# frozen_string_literal: true

module Voting::Repository
  extend self

  def votes(subject:, as_seen_by: nil)
    scope = subject.votes
    scope.merge(Vote.as_seen_by(as_seen_by))
  end

  def votes_by(user, type:, as_seen_by: nil)
    scope = if type == :post
              user.post_votes.joins("INNER JOIN posts ON posts.id = votes.subject_id AND votes.subject_type = 'Post'").merge(Post.featured)
            else
              user.public_send("#{ type }_votes")
            end
    scope.as_seen_by(as_seen_by)
  end
end
