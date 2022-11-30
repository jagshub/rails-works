# frozen_string_literal: true

class MetaTags::Generators::Question < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(subject)
  end

  def canonical_url
    @canonical_url ||= Routes.question_url(subject)
  end

  delegate :title, to: :subject

  def description
    subject.answer.truncate(160)
  end

  def image
    nil
  end

  def creator
    '@producthunt'
  end
end
