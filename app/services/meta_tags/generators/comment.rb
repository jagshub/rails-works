# frozen_string_literal: true

class MetaTags::Generators::Comment < MetaTags::Generator
  def canonical_url
    Routes.subject_url(comment.subject)
  end

  def creator
    format('@%s', comment.user.username)
  end

  # NOTE(ayrton): Strip out any HTML to show text only
  def description
    ActionView::Base.full_sanitizer.sanitize(comment.body)
  end

  def image
    Sharing.image_for(subject)
  end

  def robots
    'noindex, follow'
  end

  def title
    format('Comment on %s by %s', comment.subject_name, comment.user.name)
  end

  private

  def comment
    @comment ||= subject
  end
end
