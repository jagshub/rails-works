# frozen_string_literal: true

class ProductMailer < ApplicationMailer
  def new_launch_update(user, post)
    return if user&.email.blank?
    return unless user&.send_product_updates_email?

    email_campaign_name 'Product Follow Launch'
    @user = user
    @post = post
    @product = post.new_product
    @tracking_params = Metrics.url_tracking_params(
      medium: :email, object: 'new_launch_update',
    )

    @unfollow_url = my_subscriptions_products_url(
      @tracking_params.merge(focusId: @product.id),
    )
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(
      kind: :product_updates, user: @user,
    )

    mail to: user.email, subject: "A new launch from #{ @product.name }!"
  end

  def nudge_launch(user, product, post)
    return if user&.email.blank?
    return unless user&.send_maker_report_email?

    email_campaign_name 'Product Nudge Launch'
    @user = user
    @product = product
    @post = post
    @tracking_params = Metrics.url_tracking_params(
      medium: :email, object: 'nudge_launch',
    )

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(
      kind: :maker_report,
      user: user,
    )

    mail to: user.email, subject: "What's the latest from #{ @product.name }?"
  end
end
