# frozen_string_literal: true

class API::V1::BasicUserSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :created_at, :name, :username, :headline, :twitter_username, :website_url, :profile_url, to: :user_data_presenter
  attributes :image_url

  def image_url
    return {} if resource.trashed?

    all_image_urls.merge!(legacy_retina_urls).merge!(original_image_url)
  end

  private

  def user_data_presenter
    @data_presenter ||= API::V1::UserDataPresenter.call(resource)
  end

  def original_image_url
    { 'original' => user_image_url('original') }
  end

  def all_image_urls
    urls = {}
    Users::Avatar::LEGACY_SIZES.each do |size|
      urls["#{ size }px"] = user_image_url(size)
    end
    urls
  end

  def legacy_retina_urls
    {
      '32px@2X' => user_image_url(64),
      '40px@2X' => user_image_url(80),
      '44px@2X' => user_image_url(88),
      '88px@2X' => user_image_url(176),
      '32px@3X' => user_image_url(96),
      '40px@3X' => user_image_url(120),
      '44px@3X' => user_image_url(132),
      '88px@3X' => user_image_url(264),
    }
  end

  def user_image_url(size)
    Users::Avatar.url_for_user(resource, size: size)
  end
end
