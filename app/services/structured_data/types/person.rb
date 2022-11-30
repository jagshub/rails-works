# frozen_string_literal: true

module StructuredData::Types::Person
  extend self

  def call(user)
    return if user.trashed? || Spam::User.spammer_user?(user)

    {
      '@type': 'Person',
      'name': user.name,
      'image': Users::Avatar.url_for_user(user, size: 100),
      'url': Routes.profile_url(user),
    }
  end
end
