# frozen_string_literal: true

class MetaTags::Generators::UpcomingPageMessage < MetaTags::Generator
  def canonical_url
    Routes.upcoming_page_message_url(subject)
  end

  def creator
    user = subject.user || subject.upcoming_page.user
    "@#{ user.username }"
  end

  def author
    user = subject.user || subject.upcoming_page.user
    user.name
  end

  def author_url
    user = subject.user || subject.upcoming_page.user
    Routes.profile_url(user)
  end

  def description
    "Message about #{ subject.upcoming_page.name }"
  end

  def image
    Sharing.image_for(subject)
  end

  def title
    subject.subject.to_s
  end
end
