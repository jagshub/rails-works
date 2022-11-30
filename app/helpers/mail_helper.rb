# frozen_string_literal: true

module MailHelper
  def button_to(body, url, options = {})
    classname = options[:class].present? ? "button #{ options[:class] }" : 'button'
    rel = options[:no_track] ? 'noopener notrack' : 'noopener'

    # rubocop:disable Rails/LinkToBlank (reason: noopener is always passed, but not detected by rubocop)
    link_to body, url, class: classname, target: '_blank', rel: rel
  end

  def contact_address
    'Product Hunt Inc., 90 Gold St, FLR 3, San Francisco, CA 94133'
  end

  def article_for(word)
    %w(a e i o u).include?(word[0].downcase) ? 'an' : 'a'
  end

  def link_to_logo(url_options = {}, size:)
    link_to root_url(url_options), target: '_blank', rel: 'noopener' do
      s3_image_tag 'ph-logo-p-only.png', alt: 'Product Hunt', height: size, width: size
    end
  end

  def post_image_tag(post, size:)
    retina_size = size * 2
    image_url = post.thumbnail_url(width: retina_size, height: retina_size)

    image_tag image_url, width: size, height: size
  end

  def product_image_tag(product, size:)
    retina_size = size * 2
    image_url = product.thumbnail_url(width: retina_size, height: retina_size)

    image_tag image_url, width: size, height: size
  end

  def user_image_tag(user, size:)
    image_url = Users::Avatar.cdn_url_for_user(user)

    image_tag image_url, width: size, height: size
  end

  def job_image_tag(job, size:)
    return if job.image_uuid.blank?

    image_url = Image.call(job.image_uuid, width: size * 2, height: size * 2)
    image_tag image_url, width: size, height: size
  end

  def notification_header(subject:)
    render 'header', subject: subject
  end

  def notification_recommendation(recommendation)
    render 'recommendation', recommendation: recommendation
  end

  def notification_footer(mailer_type:)
    render 'footer', mailer_type: mailer_type
  end

  def notification_post(post)
    render 'post', post: post
  end

  def notification_comment(comment)
    render 'comment', comment: comment if comment.present?
  end

  def notification_action_button(text, url)
    render 'action_button', text: text, url: url
  end

  def nps_url(subscriber, user: nil)
    @nps_params ||= {
      email: subscriber.email,
      is_maker: user&.maker? || false,
      is_ship_pro: user&.ship_pro? || false,
    }

    "https://delighted.com/t/AvjgylBt?#{ @nps_params.to_query }"
  end

  def transactional_box(title: nil, &block)
    render 'mailer/transactional_box', { title: title }, &block
  end

  def transactional_layout(name: nil, kitty_logo: false, &block)
    render 'mailer/transactional_layout', { name: name, kitty_logo: kitty_logo }, &block
  end

  def transactional_layout_v2(name: nil, kitty_logo: false, &block)
    render 'mailer/transactional_layout_v2', { name: name, kitty_logo: kitty_logo }, &block
  end

  def transactional_salutation(version: 'simplified', salute: 'Cheers', from: 'Product Hunt team 😸', title: '')
    raise "Invalid version specified - #{ version }" unless ['simplified', 'letter'].include?(version)

    render 'mailer/transactional_salutation', version: version, salute: salute, from: from, title: title
  end

  def transactional_cta(text, href, center: false)
    class_name = 'transactional-cta'
    class_name += ' m-center' if center

    content_tag :div, button_to(text, href), class: class_name
  end

  def transactional_footnote(&block)
    render 'mailer/transactional_footnote', &block
  end

  def transactional_separtor
    content_tag :div, '', class: 'transactional-separator'
  end

  def golden_kitty_layout(phase_image: nil, &block)
    render 'mailer/golden_kitty_layout', { phase_image: phase_image }, &block
  end

  def ph_url(path: '', tracking_params: {})
    url = "https://www.producthunt.com/#{ path }"
    Metrics::UrlTrackingParams.call(url: url, medium: :email, object: tracking_params.to_query)
  end

  # NOTE(DZ): Mobile preview is pulled by certain clients from the first
  # available text content. Use this helper at the top of your email
  def mobile_preview_tag(content)
    render partial: 'mailer/mobile_preview', locals: { content: content }
  end
end
