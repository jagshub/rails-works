# frozen_string_literal: true

class MetaTags::Generators::UpcomingPageSurvey < MetaTags::Generator
  def canonical_url
    Routes.upcoming_page_survey_url(subject)
  end

  def creator
    "@#{ subject.account.user.username }"
  end

  def author
    subject.account.user.name
  end

  def author_url
    Routes.profile_url(subject.account.user)
  end

  def description
    value = subject.description || subject.welcome_text

    Sanitizers::HtmlToText.call(value) || ''
  end

  def image
    Sharing.image_for(subject)
  end

  def title
    subject.title.to_s
  end
end
