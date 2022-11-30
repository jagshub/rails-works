# frozen_string_literal: true

ActiveAdmin.register User do
  config.batch_actions = true

  actions :all, except: %i(new create)

  controller do
    def scoped_collection
      User.includes(:subscriber, :comments)
    end

    def edit
      @user = Admin::UserForm.new User.find(params[:id])
    end

    def update
      @user = Admin::UserForm.new User.find(params[:id])
      @user.update permitted_params[:user]

      respond_with @user, location: admin_users_path
    end
  end

  config.per_page = 100
  config.paginate = true

  menu label: 'Users'

  permit_params do
    permit = Admin::UserForm.attribute_names
    SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
      permit -= [attribute_name] if params[:user][attribute_name].blank?
    end
    permit
  end

  filter :id
  filter :username
  filter :name
  filter :subscriber_email, as: :string, label: 'Email'
  filter :website_url, as: :string, label: 'Website URL'
  filter :created_at, as: :date_range, label: 'Created At'
  filter :updated_at, as: :date_range, label: 'Last Updated At'
  filter :role, as: :select, collection: User.roles
  filter :posted_or_made, as: :select, label: 'Maker/Hunter'
  filter :commented, as: :select, label: 'Has Commented'
  filter :ambassador, as: :boolean

  batch_action :mark_as_spammer, confirm: "Are you sure you want to mark these users as 'spammer'?" do |ids|
    User.where(id: ids).where.not(role: :spammer).map do |user|
      SpamChecks.mark_user_as_spammer(
        user: user,
        handled_by: current_user,
        reason: 'bulk marking from admin users',
      )
    end

    redirect_to admin_users_url
  end

  index pagination_total: false do
    selectable_column
    column :id
    column 'Registered At', sortable: true, &:created_at
    column :avatar do |user|
      user_image(user, size: 45)
    end
    column :name do |user|
      formatted_user_name(user)
    end
    column :username
    column :email
    column :email_domain do |user|
      user.email ? user.email.split('@').last : nil
    end
    column :role do |user|
      formatted_user_role(user)
    end
    column :votes do |user|
      link_to user.votes.count, admin_votes_path(q: { user_id_equals: user.id })
    end
    column 'Comments' do |user|
      link_to user.comments_count, admin_commentxes_path(q: { user_id_equals: user.id })
    end
    column 'Hunter/Maker', &:maker?
    column 'Profile Website', &:website_url
    column 'Edit' do |user|
      link_to 'Edit', edit_admin_user_url(user.id)
    end
    column 'Show' do |user|
      link_to 'Show', admin_user_url(user.id)
    end
    column 'Profile' do |user|
      link_to 'Profile', profile_path(user.username)
    end
    column 'Resync' do |user|
      link_to 'Resync', resync_admin_user_url(user.id)
    end
    column 'Impersonate' do |user|
      link_to 'Impersonate', impersonate_admin_user_url(user.id)
    end
    column 'Restore' do |user|
      link_to 'Restore', edit_admin_user_restore_url(user.id)
    end
  end

  show do
    default_main_content do
      row :login_count
      row 'Header' do
        image_preview_hint(user.header_url, '', image_url_suffix: '?auto=format&w=80&h=80')
      end
      row 'Profile' do
        link_to 'Visit public profile', profile_path(user)
      end
    end

    panel 'Login methods' do
      SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
        attributes_table_for user do
          row attribute_name.to_s.delete('_uid') do
            boolean_field_tag user.public_send(attribute_name).present?
          end
        end
      end
    end

    panel 'Subscriber' do
      attributes_table_for Subscriber.for_user(user) do
        row :email
        row :verification do |subscriber|
          if subscriber.email_confirmed
            status_tag 'Verified', class: 'yes'
          elsif subscriber.verification_token.blank?
            status_tag 'Unverified', class: 'no'
          elsif subscriber.verification_token_valid?
            my_confirm_email_url token: subscriber.verification_token
          else
            status_tag 'Token expired'
          end
        end
        row :newsletter_subscription
        row :browser_push_token do |subscriber|
          boolean_field_tag(subscriber.browser_push_token.present?)
        end
        row :mobile_push_token do |subscriber|
          boolean_field_tag(subscriber.mobile_push_token.present?)
        end
        row :desktop_push_token do |subscriber|
          boolean_field_tag(subscriber.desktop_push_token.present?)
        end
        row :slack_active do |subscriber|
          boolean_field_tag(subscriber.slack_active.present?)
        end
      end
    end

    panel 'Founders Club Subscriptions' do
      subscriptions = user.payment_subscriptions.where(project: 'founder_club').order(created_at: :desc).to_a
      if subscriptions.blank?
        div 'No Founder Club subscriptions'
      else
        table_for subscriptions do
          column 'Amount' do |subscription|
            subscription.plan_amount_in_cents / 100
          end
          column :stripe_customer_id
          column :stripe_subscription_id
          column :stripe_coupon_code
          column :plan_id do |plan|
            link_to 'Plan', admin_payment_plan_path(plan)
          end
          column :claims do |_resource|
            link_to 'Claims', admin_founder_club_claims_path(q: { user_name_contains: user.name })
          end
          column 'Payment Subscription' do |subscription|
            link_to 'Payment Subscription', admin_payment_subscription_path(subscription)
          end
        end
      end
    end

    panel 'Ship Account' do
      if user.ship_account.blank? && user.ship_user_metadata.blank?
        div 'No Ship account'
      else
        attributes_table_for user.ship_account do
          row :id do |account|
            link_to account.id, admin_ship_account_path(account)
          end
          row :contacts_count
          row :upcoming_pages_count do |account|
            account.upcoming_pages.count
          end
          row :created_at
        end
        attributes_table_for user.ship_user_metadata do
          row :ship_instant_access_page
          row :trial_used
        end
      end
    end

    panel 'Ship Subscription' do
      if user.ship_subscription.blank?
        div 'No Ship subscription'
      else
        attributes_table_for user.ship_subscription do
          row :id do |subscription|
            link_to subscription.id, admin_ship_subscription_path(subscription)
          end
          row :billing_plan
          row :billing_period
          row :status
          row :cancelled_at
          row :trial_ends_at
          row :ends_at
          row :ended?
        end
      end
    end

    panel 'Billing Info' do
      if user.ship_billing_information.blank?
        div 'No billing info'
      else
        attributes_table_for user.ship_billing_information do
          row :id do |billing_information|
            link_to billing_information.id, admin_ship_billing_information_path(billing_information)
          end
          row :stripe_customer_id
          row :billing_email
          row :ship_invite_code
        end
      end
    end

    if user.oauth_applications.any?
      panel 'API Apps' do
        table_for user.oauth_applications do
          column :id
          column :name do |resource|
            link_to resource.name, admin_oauth_application_path(resource)
          end
          column :max_requests_per_hour
          column :max_points_per_hour
          column :created_at
        end
      end
    end

    panel 'Moderation Log' do
      table_for user.moderation_logs.with_preloads.order(created_at: :desc) do
        column 'Action', :message
        column :moderator
        column :created_at
      end
    end

    panel 'Upcoming Pages' do
      table_for user.upcoming_pages do
        column :id
        column :name do |upcoming_page|
          link_to upcoming_page.name, upcoming_page_path(upcoming_page)
        end
        column :tagline
        column :status
        column :created_at
        column :featured_at
        column :trashed_at
        column 'Actions' do |upcoming_page|
          link_to 'View', admin_upcoming_page_path(upcoming_page)
        end
      end
    end

    panel 'Awards' do
      table_for user.badges do
        column :id
        column :award_name do |badge|
          link_to badge.award.name, admin_badges_award_path(badge.award)
        end
        column :awarded_at, &:created_at
        column 'Actions' do |badge|
          link_to 'View', admin_badge_path(badge)
        end
      end

      div do
        link_to "see all user awards (#{ user.badges.count })", admin_badges_path(q: { subject_id_equals: user.id })
      end
    end

    panel 'Manual Spam Logs' do
      table_for user.spam_manual_logs.order(id: :desc).limit(15) do
        column :id
        column :action
        column :activity
        column :reason
        column :created_at
        column :reverted_by
        column :revert_reason
        column 'Actions' do |manual_log|
          link_to 'View', admin_spam_manual_log_path(manual_log)
        end
      end

      div do
        link_to "see all spam logs (#{ user.spam_manual_logs.count })", admin_spam_manual_logs_path(q: { user_id_equals: user.id })
      end
    end

    panel 'Spam Filter system logs' do
      table_for user.spam_action_logs.order(id: :desc).limit(15) do
        column :id
        column :subject
        column :spam
        column :action_taken_on_activity
        column :action_taken_on_actor
        column :ruleset
        column 'Actions' do |log|
          link_to 'View', admin_spam_action_log_path(log)
        end
      end

      div do
        link_to "see all spam logs (#{ user.spam_action_logs.count })", admin_spam_action_logs_path(q: { user_id_equals: user.id })
      end
    end

    panel 'Legacy Spam Logs (Manual)' do
      table_for user.spam_logs.manual.order(id: :desc).limit(20) do
        column :id
        column :content
        column :content_type
        column :action
        column :level
        column :parent_log
        column :remarks
        column :more_information
        column :kind
        column :created_at
        column :false_positive
        column 'Actions' do |spam_log|
          link_to 'View', admin_spam_log_path(spam_log)
        end
      end
      div do
        link_to "See all Spam Logs (#{ user.spam_logs.count })", admin_spam_logs_path(q: { user_id_equals: user.id })
      end
    end

    panel 'Onboarding' do
      table_for user.onboardings.order(id: :desc) do
        column :id
        column :user
        column :name
        column :status
        column :step
        column 'View' do |record|
          link_to 'View', admin_onboarding_path(record)
        end
        column 'Edit' do |record|
          link_to 'Edit', edit_admin_onboarding_path(record)
        end
      end
    end

    render 'admin/shared/audits'
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :username
      SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
        label = attribute_name.to_s.gsub(/_uid$/, '').camelcase
        f.input attribute_name, hint: "To delete, look for the \"Disconnect #{ label } Account\" button on the show page"
      end
      f.input :twitter_username, as: :string
      f.input :twitter_verified, input_html: { disabled: true }
      f.input :image
      f.input :headline
      f.input :about, as: :text
      f.input :header, as: :file, hint: image_preview_hint(f.object.header_url, '', image_url_suffix: '?auto=format&w=80&h=80')
      f.input :website_url
      f.input :role, as: :select, collection: User.roles.keys.to_a
      f.input :role_reason, as: :select, collection: User.role_reasons.keys.to_a.map { |reason| [reason.titleize, reason] }
      f.input :beta_tester, as: :boolean
      f.input :ambassador, as: :boolean
      f.input :private_profile, as: :boolean, hint: 'Will hide profile from search engines, may take a week or 2 to take effect'
      f.input :login_count, as: :number
    end

    f.inputs 'Subscriber' do
      f.input :email, label: 'Email'
      f.input :newsletter_subscription, as: :select, collection: Newsletter::Subscriptions.statuses
      f.input :email_confirmed, label: 'Verified', as: :boolean
    end

    f.inputs 'Notification Preferences' do
      welcome_notifications = flags_for :welcome
      ph_update_notifications = flags_for :ph_updates
      activity_notifications = flags_for :activity
      maker_notifications = flags_for :maker_updates
      community_notifications = flags_for :community_updates
      ship_notifications = flags_for :ship
      other_notifications = Notifications::UserPreferences::FLAGS - (welcome_notifications + ph_update_notifications + activity_notifications +
                                                                     maker_notifications + community_notifications + ship_notifications)

      li h6 'Welcome to Product Hunt Mailer'
      welcome_notifications.each do |flag|
        f.input flag, as: :boolean
      end

      li h6 'Product Hunt updates'
      ph_update_notifications.each do |flag|
        f.input flag, as: :boolean
      end

      li h6 'Activity'
      activity_notifications.each do |flag|
        f.input flag, as: :boolean
      end

      li h6 'Maker updates'
      maker_notifications.each do |flag|
        f.input flag, as: :boolean
      end

      li h6 'Community updates'
      community_notifications.each do |flag|
        f.input flag, as: :boolean
      end

      li h6 'Ship notifications'
      ship_notifications.each do |flag|
        f.input flag, as: :boolean
      end

      li h6 'Other notification flags'
      other_notifications.each do |flag|
        f.input flag, as: :boolean
      end
    end
    f.actions
  end

  action_item :new_ship_access, only: :show, if: proc { resource.ship_subscription.blank? } do
    link_to 'Grant Access to Ship', action: 'new_ship_access'
  end

  action_item :cancel_ship_subscription, only: :show, if: proc { resource.ship_subscription.present? && !resource.ship_subscription.free? && !resource.ship_subscription.cancelled? } do
    link_to 'Cancel Ship Subscription', { action: 'cancel_ship_subscription' }, 'data-confirm' => 'Are you sure? There is no turining back!'
  end

  action_item :cancel_ship_subscription_immediately, only: :show, if: proc { resource.ship_subscription.present? && !resource.ship_subscription.free? && !resource.ship_subscription.cancelled? } do
    link_to 'Cancel Ship Subscription Immediately', { action: 'cancel_ship_subscription_immediately' }, 'data-confirm' => 'Are you sure? There is no turining back!'
  end

  action_item :edit_promo_code, only: :show, if: proc { resource.ship_billing_information.present? } do
    link_to 'Edit Promo Code', action: 'edit_promo_code'
  end

  action_item :edit_ship_subscription, only: :show, if: proc { resource.ship_billing_information.present? && resource.ship_pro? } do
    link_to 'Transfer Ship Subscription', action: 'edit_ship_subscription'
  end

  action_item :edit_founder_club_subscription, only: :show, if: proc { resource.payment_subscriptions.find_by(project: 1).present? } do
    link_to 'Transfer Founder Club Subscription', action: 'edit_founder_club_subscription'
  end

  action_item :edit_ship_user_metadata, only: :show do
    link_to 'Apply Ship Invite Code', action: 'edit_ship_user_metadata'
  end

  action_item :resync, only: :show do
    link_to 'Resync Friends', action: 'resync'
  end

  action_item :disconnect_facebook, only: :show, if: proc { resource.connected_social_accounts_count > 1 } do
    link_to 'Disconnect Facebook Account', action: 'disconnect_facebook'
  end

  action_item :disconnect_twitter, only: :show, if: proc { resource.connected_social_accounts_count > 1 } do
    link_to 'Disconnect Twitter Account', action: 'disconnect_twitter'
  end

  action_item :disconnect_google, only: :show, if: proc { resource.connected_social_accounts_count > 1 } do
    link_to 'Disconnect Google Account', action: 'disconnect_google'
  end

  action_item :impersonate, only: :show do
    link_to 'Impersonate', action: 'impersonate'
  end

  action_item :gdpr_export, only: :show do
    link_to 'GDPR Export', { action: :gdpr_export }, data: { confirm: 'Are you sure you wish to GDPR export this users data?' }
  end

  action_item :gdpr_delete, only: :show do
    link_to 'GDPR Delete', { action: :gdpr_delete }, data: { confirm: 'Are you sure you wish to GDPR delete this user? THIS IS IRREVERSIBLE!' }
  end

  member_action :resync do
    FriendSync.sync_later(resource, force: true)

    redirect_to admin_user_url(resource.id), notice: 'Resync started'
  end

  member_action :disconnect_facebook do
    result = Admin::Users::DisconnectSocialAccount.call(resource, account: :facebook)

    redirect_to admin_user_url(resource.id), notice: result
  end

  member_action :disconnect_twitter do
    result = Admin::Users::DisconnectSocialAccount.call(resource, account: :twitter)

    redirect_to admin_user_url(resource.id), notice: result
  end

  member_action :disconnect_angellist do
    result = Admin::Users::DisconnectSocialAccount.call(resource, account: :angellist)

    redirect_to admin_user_url(resource.id), notice: result
  end

  member_action :disconnect_google do
    result = Admin::Users::DisconnectSocialAccount.call(resource, account: :google)

    redirect_to admin_user_url(resource.id), notice: result
  end

  member_action :new_ship_access

  member_action :grant_ship_access, method: :post do
    result = Ships::Admin::GrantAccess.call(resource, current_user, params[:ship_subscription][:billing_plan])
    notice = result ? 'Access Granted' : 'The operation has failed'

    redirect_to admin_user_url(resource.id), notice: notice
  end

  member_action :edit_promo_code do
    @ship_billing_information = resource.ship_billing_information
  end

  member_action :edit_ship_subscription do
    @user = resource
  end

  member_action :edit_founder_club_subscription do
    @user = resource
  end

  member_action :edit_ship_user_metadata do
    @ship_user_metadata = ShipUserMetadata.find_or_initialize_by(user: resource)
  end

  member_action :update_ship_subscription, method: :patch do
    result = Ships::Admin::TransferSubscription.call(resource, params[:user][:username])

    case result
    when :invalid_username
      notice = 'The username you entered is invalid'
    when :already_ship_pro
      notice = 'The user is already a Ship pro. We cannot automatically transfer the subsctription'
    when :internal_error
      notice = 'An unexpected exception has occurred. The subscription has not been transferred'
    when :receiver_have_active_account
      notice = 'The user have content in their Ship account. We cannot automatically transfer the subsctription'
    when :success
      notice = 'The subscription has been transferred'
    end

    redirect_to admin_user_url(resource.id), notice: notice
  end

  member_action :update_founder_club_subscription, method: :patch do
    result = FounderClub.admin_transfer_subscription(resource, params[:user][:username])

    case result
    when :invalid_username
      notice = 'The username you entered is invalid'
    when :active_founder_club_subscription
      notice = 'The user is already a Founder Club subscription. We cannot automatically transfer the subsctription'
    when :internal_error
      notice = 'An unexpected exception has occurred. The subscription has not been transferred'
    when :success
      notice = 'The subscription has been transferred'
    end

    redirect_to admin_user_url(resource.id), notice: notice
  end

  member_action :update_ship_user_metadata, method: :post do
    @ship_user_metadata = ShipUserMetadata.find_or_initialize_by(user: resource)
    @ship_user_metadata.ship_instant_access_page = ShipInstantAccessPage.find(params[:ship_user_metadata][:ship_instant_access_page_id])
    @ship_user_metadata.save!

    redirect_to admin_user_url(resource.id), notice: 'The user has been updated'
  end

  member_action :promo_code, method: :patch do
    ShipBillingInformation.transaction do
      ship_invite_code = ShipInviteCode.find_by(id: params[:ship_billing_information][:ship_invite_code_id])
      Ships::Admin::UpdateInviteCode.call(resource, current_user, ship_invite_code)
    end

    redirect_to admin_user_url(resource.id), notice: 'The invite code has been updated'
  end

  member_action :cancel_ship_subscription do
    result = Ships::CancelSubscription.call(user: resource, moderator: current_user)
    notice = result ? 'The subscription has been cancelled' : 'The operation has failed'

    redirect_to admin_user_url(resource.id), notice: notice
  end

  member_action :cancel_ship_subscription_immediately do
    result = Ships::CancelSubscription.call(user: resource, moderator: current_user, till_the_end_of_the_billing_period: false)
    notice = result ? 'The subscription has been cancelled' : 'The operation has failed'

    redirect_to admin_user_url(resource.id), notice: notice
  end

  member_action :impersonate do
    session[:impersonate_user_id] = resource.id
    redirect_to root_url
  end

  member_action :unsubscribe_upcoming_page, method: :delete do
    subscriber = UpcomingPageSubscriber.find(params[:upcoming_page_subscriber_id])
    Ships::Contacts::UnsubscribeSubscriber.call(subscriber, source: 'admin')
    redirect_back notice: "The user has been unsubscribed from #{ subscriber.upcoming_page.name }", fallback_location: admin_user_url(resource.id)
  end

  member_action :gdpr_export do
    Users::GDPR::ExportWorker.perform_later(user: resource)

    redirect_to admin_user_url(resource.id), notice: 'GDPR export has started, check #gdpr for updates. Do not export again!'
  end

  member_action :gdpr_delete do
    Users::GDPR::DeleteWorker.perform_later(user: resource)

    redirect_to admin_user_url(resource.id), notice: 'GDPR delete has started, check #gdpr for updates. Do not delete again!'
  end

  controller do
    def destroy
      if resource.trashed?
        # Note(LukasFittl): Just call user.restore - didn't wire up ActiveAdmin to do this (yet)
        redirect_to admin_users_path, notice: 'ERROR: User is already deleted, ask a developer if you need to restore them'
        return
      end

      resource.trash
      redirect_to admin_users_path, notice: 'User deleted'
    end
  end
end
