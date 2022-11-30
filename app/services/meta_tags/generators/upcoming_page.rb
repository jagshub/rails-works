# frozen_string_literal: true

class MetaTags::Generators::UpcomingPage < MetaTags::Generator
  def canonical_url
    Routes.upcoming_url(subject)
  end

  def creator
    "@#{ subject.user.username }"
  end

  def author
    subject.user.name
  end

  def author_url
    Routes.profile_url(subject.user)
  end

  def description
    subject.seo_description.presence || "#{ subject.name } - #{ subject.tagline } on Product Hunt"
  end

  def image
    Sharing.image_for(subject)
  end

  def title
    (subject.seo_title.presence || subject.name).to_s
  end
end
