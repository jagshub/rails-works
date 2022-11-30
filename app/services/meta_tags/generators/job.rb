# frozen_string_literal: true

class MetaTags::Generators::Job < MetaTags::Generator
  def canonical_url
    Routes.job_url(subject)
  end

  def creator
    '@producthunt'
  end

  def description
    "#{ subject.job_title } in #{ subject.locations.join(', ') }#{ subject.remote_ok && ' (Remote OK)' }"
  end

  def title
    "#{ subject.company_name } is hiring #{ subject.job_title }"
  end

  def image
    External::Url2pngApi.share_url(subject)
  end
end
