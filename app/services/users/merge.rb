# frozen_string_literal: true

module Users
  class Merge
    class << self
      # Note(andreasklinger): Split to ensure that the basics are merged asap (eg for connecting accounts)
      def basics(result_user:, trashed_user:)
        new(result_user, trashed_user).basics
      end

      def migrate_associations(result_user:, trashed_user:)
        new(result_user, trashed_user).migrate_associations
      end
    end

    def initialize(result_user, trashed_user)
      @result_user = result_user
      @trashed_user = trashed_user
    end

    def basics
      return if @trashed_user.trashed?

      # Note(rstankov): This needs go before trashing
      move_newsletter_subscriptions
      move_social_logins
      copy_role_if_needed
      copy_special

      email = @trashed_user.subscriber&.email

      move_friend_associations

      # Note(LukasFittl): This needs to go here so we can move login details easily
      @trashed_user.trash

      @result_user.save!
      @result_user.reload

      move_email(email)
    end

    def migrate_associations
      HandleRaceCondition.call do
        move_votes
        move_collection_associations
        move_collection_subscriptions
        move_access_tokens
        move_product_makers
        move_ship_account_member_associations
        move_has_many_associations
        move_has_one_associations
        move_ship_contacts
        move_maker_goals
        move_onboardings
        move_badges

        @trashed_user.reset_all_counters
        @result_user.reset_all_counters
      end
    end

    private

    def move_social_logins
      SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
        next if @result_user[attribute_name].present?
        next if @trashed_user[attribute_name].blank?

        @result_user[attribute_name] = @trashed_user[attribute_name]

        move_twitter_loggin if attribute_name == :twitter_uid
      end
    end

    def move_twitter_loggin
      @result_user.twitter_username = @trashed_user.twitter_username

      return unless @result_user.twitter_access_secret.blank? && @result_user.twitter_access_token.blank?

      @result_user.twitter_access_secret = @trashed_user.twitter_access_secret
      @result_user.twitter_access_token = @trashed_user.twitter_access_token
    end

    def copy_role_if_needed
      @result_user.role = @trashed_user.role if Users.better_role?(old_role: @result_user.role, new_role: @trashed_user.role)
    end

    def move_email(email)
      return if email.blank?
      return if @result_user.subscriber&.email.present?

      subscriber = @result_user.subscriber || @result_user.build_subscriber

      subscriber.update! email: email
    end

    def move_votes
      # Note(LukasFittl): We intentionally allow update failures here, in case of duplicates
      Vote.where(user_id: @trashed_user.id).find_each { |v| v.update(user_id: @result_user.id) }
    end

    def move_friend_associations
      @trashed_user.friends.where.not(id: @result_user.id).find_each do |friend|
        record = UserFriendAssociation.find_or_initialize_by(
          followed_by_user: @result_user,
          following_user: friend,
        )

        save_friend_association record
      end

      @trashed_user.followers.where.not(id: @result_user.id).find_each do |follower|
        record = UserFriendAssociation.find_or_initialize_by(
          following_user: @result_user,
          followed_by_user: follower,
        )

        save_friend_association record
      end

      @trashed_user.friend_ids = []
      @trashed_user.follower_ids = []

      # Note(LukasFittl): We intentionally allow update failures here, in case of duplicates
      FriendSync::Disabled.where(followed_by_user_id: @trashed_user.id).find_each { |assoc| assoc.update followed_by_user_id: @result_user.id }
      FriendSync::Disabled.where(following_user_id: @trashed_user.id).find_each { |assoc| assoc.update following_user_id: @result_user.id }
    end

    # Note(Rahul): We get NotUnique error potentially when friend sync is running in parallel
    def save_friend_association(record)
      HandleRaceCondition.call(ignore: true, max_retries: 0) do
        record.save!
      end
    end

    def move_collection_subscriptions
      @trashed_user.collection_subscriptions.find_each do |subscription|
        already_existing = @result_user.collection_subscriptions.where(collection_id: subscription.collection_id).first

        if already_existing.nil? || (already_existing.unsubscribed? && subscription.subscribed?)
          already_existing.try :destroy!
          subscription.update! user_id: @result_user.id
        else
          subscription.destroy!
        end
      end
    end

    def move_collection_associations
      Collection.where(user_id: @trashed_user.id).find_each do |collection|
        already_existing = @result_user.collections.where('name = ? OR slug = ?', collection.name, collection.slug).first
        if already_existing.nil?
          # Note(rstankov): `user_id` is marked as readonly, bypass it during user merge
          Collection.where(id: collection.id).update_all user_id: @result_user.id
        else
          collection.collection_post_associations.where(post_id: already_existing.post_ids).destroy_all
          collection.collection_post_associations.update_all collection_id: already_existing.id
          collection.destroy!
        end
      end
    end

    def move_product_makers
      ProductMaker.where(user_id: @trashed_user.id).find_each do |maker|
        if @result_user.products.where(id: maker.post_id).exists?
          maker.destroy!
        elsif maker.post.nil? || maker.post.trashed?
          maker.destroy!
        else
          maker.update! user_id: @result_user.id
        end
      end
    end

    def move_access_tokens
      @trashed_user.access_tokens.find_each do |token|
        if @result_user.access_tokens.where(token_type: AccessToken.token_types[token.token_type]).exists?
          token.destroy!
        else
          token.update! user_id: @result_user.id
        end
      end
    end

    def move_newsletter_subscriptions
      trashed_status = Newsletter::Subscriptions.status_for(user: @trashed_user)
      result_status = Newsletter::Subscriptions.status_for(user: @result_user)

      return if trashed_status == result_status
      return if trashed_status == Newsletter::Subscriptions::UNSUBSCRIBED
      return if result_status == Newsletter::Subscriptions::DAILY

      Newsletter::Subscriptions.set(user: @result_user, status: trashed_status)
    end

    def move_ship_account_member_associations
      ShipAccountMemberAssociation.where(user_id: @trashed_user.id).find_each do |record|
        if ShipAccountMemberAssociation.where(user_id: @result_user, ship_account_id: record.ship_account_id).exists?
          record.destroy!
        else
          # Note(rstankov): `user_id` is marked as readonly, bypass it during user merge
          ShipAccountMemberAssociation.where(id: record.id).update_all user_id: @result_user.id
        end
      end
    end

    def move_ship_contacts
      ShipContact.where(user_id: @trashed_user.id).find_each do |record|
        duplicate = ShipContact.find_by user_id: @result_user, ship_account_id: record.ship_account_id
        if duplicate
          Ships::Contacts::Merge.call result_contact: duplicate, delete_contract: record
        else
          ShipContact.where(id: record.id).update_all user_id: @result_user.id
        end
      end
    end

    def many_associations_helper(associations)
      associations.each do |key, models|
        models.each do |model|
          scope = model.where(key => @trashed_user.id)

          # Note(Rahul): Doing this to avoid unique key index
          duplicate_key = DUPLICATE_CHECK[model.name.to_sym]
          duplicate_key = duplicate_key.present? ? duplicate_key[key] : nil

          if duplicate_key.present?
            duplicates = model.where(key => @result_user.id).pluck(duplicate_key)

            scope = scope.where.not(duplicate_key => duplicates) if duplicates.present?
          end

          scope.update_all(key => @result_user.id)
        end
      end
    end

    MAKER_GOALS_ASSOCIATIONS = {
      user_id: [
        Goal,
        MakerGroupMember,
      ],
      assessed_user_id: [
        MakerGroupMember,
      ],
    }.freeze

    DUPLICATE_CHECK = {
      MakerGroupMember: { user_id: :maker_group_id },
    }.freeze

    def move_maker_goals
      many_associations_helper MAKER_GOALS_ASSOCIATIONS
    end

    def move_onboardings
      # Note(Rahul): Mention the onboarding you want to move and don't move user_signup & maker_profile_settings onboarding.
      onboardings = %w(maker)

      completed_onboardings = @result_user.onboardings.pluck(:name)

      to_move = onboardings.reject { |name| completed_onboardings.include? name }

      Onboarding.where(user_id: @trashed_user.id, name: to_move).update_all(user_id: @result_user.id)
    end

    def move_badges
      result_user_badge_identifiers = @result_user.badges.map(&:identifier)

      Badge.where(subject_id: @trashed_user.id, subject_type: 'User').find_each do |trashed_user_badge|
        award = UserBadges.award_for(identifier: trashed_user_badge.identifier)
        next if !award.stackable? && result_user_badge_identifiers.include?(trashed_user_badge.identifier)

        trashed_user_badge.update!(subject_id: @result_user.id)
      end
    end

    HAS_ONE_ASSOCIATIONS = %i(
      ship_subscription
      ship_billing_information
      ship_user_metadata
      ship_account
    ).freeze

    def move_has_one_associations
      HAS_ONE_ASSOCIATIONS.each do |association_name|
        record = @trashed_user.public_send(association_name)

        next if record.blank?
        next unless @result_user.public_send(association_name).nil?

        record.update! user_id: @result_user.id
      end
    end

    HAS_MANY_ASSOCIATIONS = {
      user_id: [
        Comment,
        LinkTracker,
        ProductMaker,
        Media,
        Post,
        LegacyProductLink,
        UpcomingPage,
      ],
    }.freeze

    def move_has_many_associations
      many_associations_helper HAS_MANY_ASSOCIATIONS
    end

    # NOTE(DZ): Special rules that are part of our business
    def copy_special
      # NOTE(DZ): Resulting user should be the older of the two
      @result_user.created_at = [
        @result_user.created_at,
        @trashed_user.created_at,
      ].min
    end
  end
end
