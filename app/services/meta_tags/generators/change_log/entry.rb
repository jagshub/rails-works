# frozen_string_literal: true

class MetaTags::Generators::ChangeLog::Entry < MetaTags::Generator
  def canonical_url
    Routes.change_log_url(subject)
  end

  def creator
    '@producthunt'
  end

  def description
    return 'Our latest update on Product Hunt’s changelog' unless subject.description_html

    Sanitizers::HtmlToText.call(subject.description_html)
  end

  def title
    subject.title.to_s
  end

  def image
    External::Url2pngApi.share_url(subject)
  end
end
