# frozen_string_literal: true

module Comments::Badges
  extend self

  def call(comment)
    case comment.subject_type
    when 'Post'
      return get_post_badges(comment.subject, comment.user_id)
    end

    []
  end

  private

  # Note(Rahul): We return array because a comment can have multiple badges like hunter, AMA, hiring etc..
  def get_post_badges(post, commented_by)
    badges = []

    if post.maker_ids.include? commented_by
      badges.push('maker')
    elsif post.user_id == commented_by
      badges.push('hunter')
    end

    badges
  end
end
