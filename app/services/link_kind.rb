# frozen_string_literal: true

module LinkKind
  extend self

  KINDS = {
    'twitter' => %r{\Ahttps?://twitter\.com/.*\z}i,
    'facebook' => %r{\Ahttps?://.*facebook\.com/.*\z}i,
    'angellist' => %r{\Ahttps?://angel\.co/.*\z}i,
    'play_store' => %r{\Ahttps?://play\.google\.com/store/apps/details\?id=.*\z}i,
    'instagram' => %r{\A.*https?://www\.instagram\.com.*\z}i,
    'github' => %r{\A.*https?://github\.com.*\z}i,
    'app_store' => Regexp.union(
      %r{\Ahttps?://itunes\.apple\.com/WebObjects/MZStore.woa/wa/viewSoftware\?id=\d+.*\z}i,
      %r{\Ahttps?://itunes\.apple\.com(/[\w-]+){2,4}.*\z}i, # itunes.apple.com/(COUNTRY/)app/PUBLISHER/idID
      %r{\Ahttps?://appstore.com(/[\w-]+){1,3}.*\z}i, # appstore.com/COMPANY/APPNAME
      %r{\Ahttps?://appsto.re(/[\w-]+){2,4}.*\z}i, # appsto.re/COUNTRY/SHORTCODE
      %r{\Ahttps?://apps\.apple\.com(/[\w-]+){2,4}}i, # apps.apple.com/(COUNTRY/)app/PUBLISHER/idID
      %r{\Ahttps?://testflight.apple.com/join/.*\z}i, # testflight.apple.com/join/INVITE
    ),
    'website' => URI::DEFAULT_PARSER.make_regexp,
    'privacy_policy' => URI::DEFAULT_PARSER.make_regexp,
  }.freeze

  WEBSITE = 'website'

  def match_kind?(url, kind:)
    regexp = KINDS[kind.to_s]
    regexp&.match?(url)
  end

  def valid_kind?(kind)
    KINDS[kind.to_s].present?
  end
end
