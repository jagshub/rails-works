# frozen_string_literal: true

class MetaTags::Generators::User < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(subject)
  end

  def canonical_url
    @canonical_url ||= Routes.profile_url(subject.username)
  end

  def creator
    format('@%s', subject.username)
  end

  def description
    format('See what kind of products %s (%s) likes on Product Hunt', subject.name, subject.headline)
  end

  def image
    External::Url2pngApi.share_url(subject)
  end

  def robots
    return 'noindex, nofollow' if subject.private_profile || Spam::User.spammer_user?(subject)
  end

  def title
    format('%s profile on Product Hunt', apostrophe_name(subject.name || subject.username))
  end

  def type
    'profile'
  end

  def apostrophe_name(name)
    apostrophe = name.downcase.end_with?('s') ? "'" : "'s"
    name + apostrophe
  end
end
