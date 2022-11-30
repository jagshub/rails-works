# frozen_string_literal: true

module PlatformStores
  extend self

  UUID_REGEX = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
  DIRECTORIES_ENDING_IN_SLASH = '([a-z0-9\-]+/)+'

  WEBSITE = 'Website'
  OTHER = 'Other'

  # NOTE(DZ): When adding additional support, ensure that house keeper works
  # when link is broken => app/services/house_keeper/maintain.rb
  # NOTE(AR): Not sorted alphabetically, because some checkers need to go
  # before others.
  STORES = [
    AmazonStore,
    AndroidStore,
    ChromeStore,
    ITunesStore,
    IOSStore,
    NintendoStore,
    PlaystationStore,
    SteamStore,
    WindowsStore,
    XboxStore,
    YoutubeStore,
    OvercastStore,
    TuneInStore,
    StitcherStore,
    GithubStore,
    KickstarterStore,
    IndiegogoStore,
    SlackStore,
    MessengerStore,
    VisualStudioStore,
    PodcastsStore,
    NotionStore,
    LoomStore,
    ShopifyStore,
    FacebookStore,
    MediumStore,
    NpmStore,
    EtsyStore,
    GumroadStore,
    FigmaStore,
    VercelStore,
    OpenseaStore,
    WebflowStore,
    GoogleStore,
    LeanpubStore,
    TwitterStore,
  ].freeze

  def enums
    get_store_with :enum
  end

  def names
    get_store_with :name
  end

  def find_name_for_store(key)
    stores(key).name
  end

  def find_os_for_store(key)
    stores(key).os
  end

  def store_key_by_url(url)
    store_by_url(url).key
  end

  def match_by_url(url)
    store_by_url(url).match_url(url)
  end

  private

  def store_by_url(url)
    return NullStore if url.blank?

    STORES.find { |store| store.match_url(url).present? } || NullStore
  end

  def stores(key)
    return NullStore if key.blank?

    key = key.to_sym
    STORES.find { |store| store.key == key } || NullStore
  end

  def get_store_with(attribute_name)
    STORES.each_with_object({}) do |store, hash|
      hash[store.key] = store.public_send(attribute_name)
      hash
    end
  end
end
