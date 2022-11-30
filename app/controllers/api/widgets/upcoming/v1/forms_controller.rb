# frozen_string_literal: true

class API::Widgets::Upcoming::V1::FormsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_origin

  WWW_HOST = 'https://www.producthunt.com'

  def create
    upcoming_page = UpcomingPage.friendly.find(params[:upcoming_id])

    subscriber = Ships::Contacts::CreateSubscriber.from_subscription(
      subscription_target: upcoming_page,
      email: params[:email],
      source_kind: 'form_widget',
    )

    if subscriber.nil?
      redirect_to redirect_to_path(slug: upcoming_page.slug)
      return
    end

    redirect_to redirect_to_path(slug: upcoming_page.slug, errors: subscriber.errors.full_messages.join(','), email: params[:email])
  end

  private

  # NOTE(vesln): redirect from api. to www.
  def redirect_to_path(query)
    if Rails.env.development?
      upcoming_page_form_path(query)
    else
      WWW_HOST + upcoming_page_form_path(query)
    end
  end
end
