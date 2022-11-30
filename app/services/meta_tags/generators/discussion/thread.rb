# frozen_string_literal: true

class MetaTags::Generators::Discussion::Thread < MetaTags::Generator
  delegate :title, to: :subject
  delegate :description, to: :subject

  def canonical_url
    Routes.discussion_url(subject)
  end

  def creator
    format('@%s', subject.user.username)
  end

  def author
    subject.user.name
  end

  def author_url
    Routes.profile_url(subject.user)
  end

  def image
    External::Url2pngApi.share_url(subject)
  end

  def robots
    'noindex, nofollow' unless subject.approved?
  end
end
