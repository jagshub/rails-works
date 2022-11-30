# frozen_string_literal: true

class ProductMakers::CreateMakerSuggestion
  NON_CREDIBLE_ROLES = %w(spammer company).freeze

  attr_reader :invited_by, :maker, :post, :user

  class << self
    def call(invited_by:, maker:)
      new(invited_by: invited_by, maker: maker).call
    end
  end

  def initialize(invited_by:, maker:)
    @invited_by = invited_by
    @maker = maker
    @post  = maker.post
    @user  = maker.user
  end

  def call
    return false if maker.username.blank? || non_credible?

    maker_suggestion.save!
    post.touch
    maker_suggestion
  end

  private

  def non_credible?
    user.present? && NON_CREDIBLE_ROLES.include?(user.role)
  end

  def maker_suggestion
    @maker_suggestion ||=
      MakerSuggestion.find_or_initialize_by(post_id: post.id, maker_username: maker.username) do |assoc|
        assoc.maker ||= user
        assoc.invited_by ||= invited_by
      end
  end
end
