# frozen_string_literal: true

class Notifications::Helpers::DefaultValues
  DEFAULT_VALUES = {
    'Collection' => Notifications::Helpers::DefaultValues::CollectionValues,
    'Comment' => Notifications::Helpers::DefaultValues::CommentValues,
    'MakerGroupMember' => Notifications::Helpers::DefaultValues::MakerGroupMemberValues,
    'Post' => Notifications::Helpers::DefaultValues::PostValues,
    'User' => Notifications::Helpers::DefaultValues::UserValues,
    'Vote' => Notifications::Helpers::DefaultValues::VoteValues,
  }.freeze

  class << self
    def for(object)
      klass = DEFAULT_VALUES.fetch(object.class.name, Notifications::Helpers::DefaultValues::FallbackValues)
      klass.new(object)
    end
  end
end
