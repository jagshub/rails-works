# frozen_string_literal: true

module ProductMakers
  extend self

  def accept(maker:)
    log by: maker.user, maker: maker, message: 'Joined as maker', color: :green do
      ProductMakers::AcceptMakerSuggestion.call(maker: maker)
    end
  end

  def add(by:, maker:)
    suggestion = ProductMakers::CreateMakerSuggestion.call(invited_by: by, maker: maker)
    return false unless suggestion

    log by: by, maker: maker, message: 'Added a maker', color: :green do
      ProductMakers::ApproveMakerSuggestion.call(approved_by: by, maker: maker)
    end
  end

  def remove(by:, maker:)
    log by: by, maker: maker, message: 'Removed as maker', color: :red do
      ProductMakers::RemoveMaker.call(maker: maker)
    end
  end

  def makers_of(post:)
    ProductMakers::MakersOf.call(post)
  end

  # Note(andreasklinger): Passing `post_id` instead of `post` to avoid unnecessary loading of post.
  def maker_of?(user:, post_id:)
    return false if user.blank?

    # Note(andreasklinger): Using `map` instead of `pluck` to ensure we are not generating
    #   new select sql queries but hit the cache with the old one.
    associations = ProductMaker.where(post_id: post_id)
    associations.map(&:user_id).include? user.id
  end

  private

  def log(by:, maker:, message:, color: nil)
    yield if block_given?
    attachment = Moderation::Notifier.for_maker(author: by, maker: maker, message: message, color: color)
    attachment.notify
  end
end
