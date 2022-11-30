# frozen_string_literal: true

class Users::GDPR::Export
  def initialize(user: nil)
    @user = user
    @subscriber = @user.try(:subscriber)
    @data = {}
  end

  def invoke!
    gather_data
    package_data
    email_data
    notify_slack
  end

  private

  def gather_data # rubocop:disable Metrics/AbcSize
    known_emails = [@subscriber&.email].compact
    known_ips = [] # NOTE (k1): Temporarily disabled as IP resolution can cause unintended cascades in the data dump

    @data[:checkout_page_logs] = csvify(CheckoutPageLog.where(user_id: @user.id))
    @data[:collection_subscriptions] = csvify(CollectionSubscription.where(email: known_emails).or(CollectionSubscription.where(user_id: @user.id)))
    @data[:collections] = csvify(Collection.where(user_id: @user.id)) { |row| row.as_json(except: ['featured_at', 'post_ids_minhash_signature']) }
    @data[:comments] = csvify(Comment.where(user_id: @user.id)) { |row| row.as_json(except: ['credible_votes_count', 'sticky', 'hidden_at']) }
    @data[:cookie_policy_logs] = csvify(CookiePolicyLog.where(user_id: @user.id).or(CookiePolicyLog.where(ip_address: known_ips)))
    @data[:dismissables] = csvify(Dismissable.where(user_id: @user.id))
    @data[:file_exports] = csvify(FileExport.where(user_id: @user.id))
    @data[:flags] = csvify(Flag.where(user_id: @user.id))
    @data[:goals] = csvify(Goal.where(user_id: @user.id))
    @data[:link_trackers] = csvify(LinkTracker.where(user_id: @user.id).or(LinkTracker.where(ip_address: known_ips)))
    @data[:maker_group_members] = csvify(MakerGroupMember.where(user_id: @user.id))
    @data[:mentions] = csvify(Mention.where(user_id: @user.id))
    @data[:newsletter_events] = csvify(NewsletterEvent.where(subscriber: @subscriber).or(NewsletterEvent.where(ip: known_ips)))
    @data[:notification_logs] = csvify(NotificationLog.where(subscriber: @subscriber))
    @data[:notification_subscription_logs] = csvify(NotificationSubscriptionLog.where(subscriber: @subscriber))
    @data[:notification_unsubscription_logs] = csvify(NotificationUnsubscriptionLog.where(subscriber: @subscriber))
    @data[:notification_subscribers] = csvify(Subscriber.where(user_id: @user.id).or(Subscriber.where(email: known_emails)))
    @data[:post_topic_associations] = csvify(PostTopicAssociation.where(user_id: @user.id))
    @data[:posts] = csvify(Post.where(user_id: @user.id)) { |row| row.as_json(except: ['credible_votes_count', 'votes_count', 'featured_at', 'link_visits', 'link_unique_visits']) }
    @data[:product_links] = csvify(LegacyProductLink.where(user_id: @user.id))
    @data[:product_makers] = csvify(ProductMaker.where(user_id: @user.id))
    @data[:media] = csvify(Media.where(user_id: @user.id))
    @data[:product_requests] = csvify(ProductRequest.where(user_id: @user.id))
    @data[:promoted_analytics] = csvify(PromotedAnalytic.where(user_id: @user.id))
    @data[:recommendations] = csvify(Recommendation.where(user_id: @user.id)) { |row| row.as_json(except: ['credible_votes_count']) }
    @data[:reviews] = csvify(Review.where(user_id: @user.id)) { |row| row.as_json(except: ['credible_votes_count', 'score', 'score_multiplier']) }
    @data[:ship_account_member_associations] = csvify(ShipAccountMemberAssociation.where(user_id: @user.id))
    @data[:ship_accounts] = csvify(ShipAccount.where(user_id: @user.id))
    @data[:ship_billing_informations] = csvify(ShipBillingInformation.where(user_id: @user.id).or(ShipBillingInformation.where(billing_email: known_emails))) { |row| row.as_json(except: ['stripe_token_id', 'stripe_customer_id']) }
    @data[:ship_cancellation_reasons] = csvify(ShipCancellationReason.where(user_id: @user.id))
    @data[:ship_contacts] = csvify(ShipContact.where(user_id: @user.id).or(ShipContact.where(ip_address: known_ips)).or(ShipContact.where(email: known_emails)))
    @data[:ship_leads] = csvify(ShipLead.where(user_id: @user.id).or(ShipLead.where(email: known_emails)))
    @data[:ship_subscriptions] = csvify(ShipSubscription.where(user_id: @user.id))
    @data[:ship_user_metadatas] = csvify(ShipUserMetadata.where(user_id: @user.id))
    @data[:subscriptions] = csvify(Subscription.where(subscriber: @subscriber))
    @data[:topic_user_associations] = csvify(TopicUserAssociation.where(user_id: @user.id))
    @data[:upcoming_page_conversation_messages] = csvify(UpcomingPageConversationMessage.where(user_id: @user.id))
    @data[:upcoming_page_messages] = csvify(UpcomingPageMessage.where(user_id: @user.id))
    @data[:upcoming_pages] = csvify(UpcomingPage.where(user_id: @user.id))
    @data[:user_delete_surveys] = csvify(UserDeleteSurvey.where(user_id: @user.id))
    @data[:user_follow_product_request_associations] = csvify(UserFollowProductRequestAssociation.where(user_id: @user.id))
    @data[:user_friend_associations] = csvify(UserFriendAssociation.where(followed_by_user_id: @user.id))
    @data[:users] = csvify(User.where(id: @user.id)) { |row| row.as_json(except: ['role', 'twitter_access_token', 'twitter_access_secret']) }
    @data[:vote_infos] = csvify(VoteInfo.where(request_ip: known_ips).or(VoteInfo.where(vote_id: Vote.where(user_id: @user.id))))
    @data[:votes] = csvify(Vote.where(user_id: @user.id)) { |row| row.as_json(except: ['sandboxed', 'credible']) }

    @data.reject! { |_key, value| value.string.empty? }
  end

  def csvify(query, &block)
    csv = CSV.new(+'')

    columns = Hash[query.model.columns.map { |column| [column.name, column.type] }]

    query.each_row do |row|
      row = block.call(row) if block_given?

      row.each do |key, value|
        # NOTE (k1): Convert ISO8601 dates into integer unix timestamps to save space
        row[key] = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::DateTime.new.cast_value(value).to_i if columns[key] == :datetime
      end

      csv << row.keys if csv.lineno == 0
      csv << row.values
    end

    csv
  end

  def package_data
    @zip = Zip::OutputStream.write_buffer do |zio|
      @data.each do |key, value|
        zio.put_next_entry("#{ key }.csv", nil, nil, Zip::Entry::DEFLATED, Zlib::BEST_COMPRESSION)
        zio.write(value.string)
      end
    end.string
  end

  def email_data
    GdprExportMailer.export_was_generated(email: @subscriber.email, zip: @zip).deliver_now
  end

  def notify_slack
    return unless Rails.env.production?

    SlackNotify.call(
      channel: 'gdpr',
      text: "GDPR export has been sent for user #{ @user.id }",
      username: 'GDPR',
      icon_emoji: ':closed_lock_with_key:',
      attachment: {
        fields: [
          @data.map do |key, value|
            { title: key.to_s.titlecase, value: value.string.length, short: true }
          end,
          { title: 'Zip Size', value: @zip.length, short: true },
        ].flatten,
      },
    )
  end
end
