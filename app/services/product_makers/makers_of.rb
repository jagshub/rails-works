# frozen_string_literal: true

module ProductMakers::MakersOf
  extend self

  def call(post)
    # Note(andreasklinger): Almost every maker relationship was once a suggestion in our system
    makers = post.maker_suggestions.map do |suggestion|
      ProductMakers::Maker.from_suggestion(suggestion)
    end

    # Note(andreasklinger): We have around 10% makers w/o maker suggestions still in the system
    # TODO(andreasklinger): Create maker suggestions for those legacy makers
    legacy_maker_users = post.makers.reject do |maker|
      makers.map(&:username).include? maker.username
    end

    legacy_makers = legacy_maker_users.map do |user|
      ProductMakers::Maker.new(user: user, post: post)
    end

    makers + legacy_makers
  end
end
