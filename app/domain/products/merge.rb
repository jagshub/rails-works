# frozen_string_literal: true

module Products::Merge
  extend self

  # Note(AR): "Source" will be destroyed after this runs, and all of its posts
  # will be moved to "Target".
  def take_posts(source:, target:, user:)
    return if source == target

    unless ApplicationPolicy.can?(user, :moderate, source) && ApplicationPolicy.can?(user, :moderate, target)
      raise "Unauthorized user tried to merge products #{ source.name } -> #{ target.name }"
    end

    Product.transaction do
      source.posts.each do |post|
        Products::MovePost.call(post: post, product: target, source: 'merge')
      end

      source
        .subscriptions
        .where.not(subscriber_id: target.subscriptions.select(:subscriber_id))
        .update_all(subject_id: target.id)
      target.refresh_followers_count

      source_slugs = source.slugs.pluck(:slug)

      source.trash

      source_slugs.each { |slug| FriendlyId::Slug.create!(sluggable: target, slug: slug) }

      ModerationLog.create!(
        reference: target,
        message: ModerationLog::MERGED_PRODUCTS,
        reason: "Merged product '#{ source.name }' into '#{ target.name }'",
        moderator: user,
      )
    end

    Products::RefreshActivityEventsWorker.perform_later(target.reload)
  end
end
