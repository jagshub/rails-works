# frozen_string_literal: true

module Users::LinkKind
  extend self

  KINDS = {
    'twitter' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?twitter\.com/.*\z}i,
    'facebook' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?facebook\.com/.*\z}i,
    'angellist' => %r{\Ahttps?://angel\.co/.*\z}i,
    'play_store' => %r{\Ahttps?://play\.google\.com/store/apps/details\?id=.*\z}i,
    'instagram' => %r{\A.*https?://(?:[a-zA-Z]+\.)?instagram\.com.*\z}i,
    'github' => %r{\A.*https?://(?:[a-zA-Z]+\.)?github\.com.*\z}i,
    # Note(JL): Platform store regexes taken from Ship LinkKind service but can also be
    # found in PlatformStores
    'app_store' => Regexp.union(
      %r{\Ahttps?://itunes\.apple\.com/WebObjects/MZStore.woa/wa/viewSoftware\?id=\d+.*\z}i,
      %r{\Ahttps?://itunes\.apple\.com(/[\w-]+){2,4}.*\z}i, # itunes.apple.com/(COUNTRY/)app/PUBLISHER/idID
      %r{\Ahttps?://appstore.com(/[\w-]+){1,3}.*\z}i, # appstore.com/COMPANY/APPNAME
      %r{\Ahttps?://appsto.re(/[\w-]+){2,4}.*\z}i, # appsto.re/COUNTRY/SHORTCODE
      %r{\Ahttps?://apps\.apple\.com(/[\w-]+){2,4}}i, # apps.apple.com/(COUNTRY/)app/PUBLISHER/idID
      %r{\Ahttps?://testflight.apple.com/join/.*\z}i, # testflight.apple.com/join/INVITE
    ),
    'linkedin' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?linkedin\.com/.*\z}i,
    'youtube' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?youtube\.com/.*\z}i,
    'tiktok' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?tiktok\.com/.*\z}i,
    'reddit' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?reddit\.com/.*\z}i,
    'dribbble' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?dribbble\.com/.*\z}i,
    'behance' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?behance\.net/.*\z}i,
    'vimeo' => %r{\Ahttps?://(?:[a-zA-Z]+\.)?vimeo\.com/.*\z}i,
    'website' => URI::DEFAULT_PARSER.make_regexp,
  }.freeze

  def kind_from_url(url)
    KINDS.find { |_kind, regexp| regexp.match?(url) }&.first
  end
end
