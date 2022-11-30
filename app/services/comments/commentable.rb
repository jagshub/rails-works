# frozen_string_literal: true

class Comments::Commentable
  attr_accessor :subject

  def initialize(subject)
    @subject = subject
  end

  def name
    case subject
    when Anthologies::Story
      subject.title
    when Discussion::Thread
      subject.title
    when Goal
      BetterFormatter.strip_tags(subject.title_html)
    when Post
      subject.name
    when ProductRequest
      subject.title
    when Recommendation
      "#{ subject.product_request.title } (recommendation)"
    when Review
      "#{ (subject.product || subject.post).name } (review)"
    when UpcomingPageMessage
      subject.subject
    else
      raise ArgumentError, "Unknown subject type #{ subject.class }"
    end
  end
end
