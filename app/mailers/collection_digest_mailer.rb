# frozen_string_literal: true

class CollectionDigestMailer < ApplicationMailer
  def updated_collections(email:, collections:, recommended_collections: nil, user: nil)
    email_campaign_name 'collection_digest_update'

    @presenter = CollectionDigestPresenter.new(collections)
    @user = user
    @email = email
    @recommended_collections = recommended_collections

    mail(to: email, from: CommunityContact.default_from, subject: @presenter.subject,
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end
end
