# frozen_string_literal: true

class CollectionDigestWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  queue_as :notifications

  def perform(user_id: nil, email: nil)
    collection_digest = Collections::EmailDigest.new(user_id, email)

    return if collection_digest.disabled?
    return unless collection_digest.collections?
    return if collection_digest.user_email.blank?

    CollectionDigestMailer.updated_collections(
      email: collection_digest.user_email,
      collections: collection_digest.collections,
      recommended_collections: collection_digest.recommended_collections,
      user: collection_digest.user,
    ).deliver_now
  end
end
