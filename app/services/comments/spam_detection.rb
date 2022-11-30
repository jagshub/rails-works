# frozen_string_literal: true

class Comments::SpamDetection
  def initialize(comment)
    @body = comment.body
    @sanitized_body = Sanitizers::HtmlToText.call(comment.body)
    @comments_to_check = Comment.where(user_id: comment.user_id).where('created_at > ?', 1.day.ago)
    @comments_to_check = @comments_to_check.where.not(id: comment.id) if comment.persisted?
    @maker_hunter_of_post = maker_hunter_of_post?(comment)
  end

  def spam?
    link_in_body_aready_posted? ||
      email_in_body_already_posted? ||
      body_already_posted? ||
      body_contains_only_links? ||
      body_is_only_user_or_maker_tag?
  end

  private

  attr_reader :body, :sanitized_body, :comments_to_check, :maker_hunter_of_post

  def body_already_posted?
    return false if body.to_s.size <= 10

    comments_to_check.where(body: body).any?
  end

  def link_in_body_aready_posted?
    return false if maker_hunter_of_post

    urls = URI.extract(sanitized_body.to_s).map { |u| UrlParser.clean_url(u) }.uniq.compact
    return false if urls.empty?

    comment_scope = urls.reduce(Comment.all) do |scope, url|
      if url == urls.first
        scope.where('LOWER(body) LIKE ?', LikeMatch.simple(url))
      else
        scope.or(Comment.where('LOWER(body) LIKE ?', LikeMatch.simple(url)))
      end
    end
    comments_to_check.merge(comment_scope).any?
  end

  EMAIL_REGEXP = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i.freeze

  def email_in_body_already_posted?
    return false if maker_hunter_of_post

    emails = sanitized_body.to_s.scan(EMAIL_REGEXP).uniq.compact
    return false if emails.empty?

    comment_scope = emails.reduce(Comment.all) do |scope, email|
      if email == emails.first
        scope.where('LOWER(body) LIKE ?', LikeMatch.simple(email))
      else
        scope.or(Comment.where('LOWER(body) LIKE ?', LikeMatch.simple(email)))
      end
    end
    comments_to_check.merge(comment_scope).any?
  end

  # Note(TDC): Get the text that is not enclosed in <a> html tags to get
  # the meaningful content of the comment body. The use of xpath
  # ensures we only get the top level content of the node and not
  # the node + its children
  def unlinked_text_content
    Nokogiri::HTML(body).css(':not(a)').map { |el| el.xpath('text()').text }.join('')
  end

  # Note(TDC): This checks an entire body string as an html element. If there is no
  # top level text under this hypothetical <body> html string - then its all
  # links or tags and its likely spam. We check if the text at the top
  # level is all non-blank. This would also check so that an empty space does not validate
  def body_contains_only_links?
    text_content = unlinked_text_content

    text_content.nil? || text_content.blank?
  end

  # Note(TDC): This check that the body is not just a user tag
  # or a ?makers tag that has no other text content. This is a redimentary
  # check that keeps people from spamming the ?makers tag or a mention
  def body_is_only_user_or_maker_tag?
    text_content = unlinked_text_content << ' '
    filtered_text = text_content.gsub(/@(.*?)\s/, '').gsub('?makers', '')

    filtered_text.nil? || filtered_text.blank?
  end

  # Note(TDC): There are some checks we may wish to skip when the commenter is
  # a maker or hunter of a given post. This only applies to comments for posts
  def maker_hunter_of_post?(comment)
    return false unless comment.subject_type == 'Post'

    comment.user_id == comment.subject.user_id ||
      comment.subject.visible_makers.map(&:id).include?(comment.user_id)
  end
end
