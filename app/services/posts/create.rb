# frozen_string_literal: true

class Posts::Create
  def self.call(user:, params:, request_info: {})
    new(user: user, post: user.posts.new).call(params, request_info)
  end

  attr_reader :user, :post, :primary_link

  def initialize(user:, post:)
    @user = user
    @post = post
    @primary_link = post.primary_link || post.build_primary_link(user: user)
  end

  def call(params, request_info)
    attributes = Posts::Submission::Attributes.new(params, user)

    ActiveRecord::Base.transaction do
      add_attributes(attributes)
      add_description_length(post)

      Posts::Submission::SetDates.call(
        post: post,
        user: user,
        featured_at: attributes.featured_at,
      )

      Posts::Submission::SetAdditionalLinks.call(post: post, user: user, links: attributes.additional_links)

      Audited.audit_class.as_user(user) do
        post.save!
      end

      primary_link.save!

      protect_from_duplicates

      Posts::Submission::SetMedia.call(
        post: post,
        user: user,
        media: attributes.media,
        thumbnail_image_uuid: attributes.thumbnail_image_uuid,
      )
      Posts::Submission::SetMakers.call(user: user, post: post, makers: attributes.makers)
      Posts::Submission::SetTopics.call(post: post, user: user, topic_ids: attributes.topic_ids)
      Posts::Submission::SetCommentPrompts.call(post: post, comment_prompts: attributes.comment_prompts)

      create_funding_survey_if_needed(post, params)

      Moderation.change_multiplier(by: user, post: post, multiplier: attributes.multiplier) if user.admin?
      Comments::CreateForm.new(user: user, source: :application, request_info: request_info, skip_spam_check: true).update!(attributes.comment.merge(subject: post)) if attributes.comment.present?
      Voting.create(subject: post, user: user, source: :application)
      update_draft_post(uuid: attributes.draft_uuid)
    end

    Metrics.track_create(user: user, type: 'post', options: { name: post.name, url: post.url, tagline: post.tagline })

    Posts::NotifyAboutPostSubmissionWorker.perform_later(post)

    draft = update_draft_post(uuid: attributes.draft_uuid)
    find_or_create_product(post, params, draft)

    emit_iterable_event(post, user)

    post
  end

  private

  def protect_from_duplicates
    duplicate_urls = Posts::Duplicates.duplicated_links(post)
    return if duplicate_urls.blank?

    post.errors.add(:url, "Links already posted: #{ duplicate_urls.join(', ') }")
    raise ActiveRecord::RecordInvalid, post
  end

  def add_attributes(attributes)
    primary_link.attributes = attributes.primary_link unless attributes.primary_link.nil?
    post.attributes = attributes.post unless attributes.post.nil?
  end

  def add_description_length(post)
    description_text = Sanitizers::HtmlToText.call(post.description, extract_attr: false)
    post.description_length = description_text.nil? ? 0 : description_text.length
  end

  def update_draft_post(uuid:)
    draft = user.post_drafts.find_by_uuid(uuid)
    return if draft.nil?

    draft.update!(post: post)
    draft
  end

  def find_or_create_product(post, params, draft)
    product = draft&.suggested_product || Products::Find.by_url(post.primary_link.url)

    if create_new_product?(draft, product)
      product = Products::Create.for_post(post, product_source: 'post_create')
    else
      Products::MovePost.call(post: post, product: product, source: 'post_create')
    end

    product.update!(twitter_url: NormalizeTwitter.url(params[:product_twitter_handle]))
    TwitterFollowers.sync(subject: product)

    Products::RefreshActivityEventsWorker.perform_later(product)
  end

  def create_new_product?(draft, product)
    return true if product.blank?
    return false if draft.blank?

    # Note(Rahul): We ask users in UI if they want to connect with the suggested product
    #              and when they say no & product we found by url is same then
    #              we need to create a new product.
    !draft.connect_product? && draft.suggested_product_id == product.id
  end

  def emit_iterable_event(post, user)
    product = Product.find_by(id: post.product_id) if post.product_id.present?

    data_fields = {
      launch_name: post.name,
      tagline: post.tagline,
      product_name: product&.name,
      launch_scheduled_at: post.scheduled_at.strftime('%Y-%m-%d %H:%M:%S %:z'),
      scheduled_date: post.scheduled_at&.strftime('%d/%m/%Y'),
      scheduled_time: post.scheduled_at&.strftime('%H:%M:%S'),
      is_first_product_of_user: user.products&.count == 1,
      thumbnail_image_url: Image::BASE_URL + '/' + post.thumbnail_image_uuid,
      primary_link: post.primary_link&.url,
      post_slug: post.slug,
    }
    Iterable.trigger_event(
      post.scheduled? ? 'post_launch_scheduled' : 'post_launched',
      email: user.email,
      user_id: user.id,
      data_fields: data_fields,
    )
  end

  SURVEY_ATTRIBUTES = %i(
    have_raised_vc_funding
    funding_round
    funding_amount
    interested_in_vc_funding
    interested_in_being_contacted
    share_with_investors
  ).freeze

  def create_funding_survey_if_needed(post, params)
    attributes = params.slice(*SURVEY_ATTRIBUTES).compact

    return if attributes.empty?

    survey = post.funding_survey || post.build_funding_survey
    survey.update!(attributes)
  end
end
