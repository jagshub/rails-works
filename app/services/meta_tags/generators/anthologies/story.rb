# frozen_string_literal: true

class MetaTags::Generators::Anthologies::Story < MetaTags::Generator
  def title
    subject.title.to_s
  end

  def description
    subject.description&.delete('"')
  end

  def creator
    "@#{ subject.author.username }"
  end

  def canonical_url
    Routes.story_url(subject)
  end

  def image
    Sharing.image_for(subject)
  end

  def type
    'article'
  end

  def author
    subject.author.name
  end

  def author_url
    Routes.profile_url(subject.author)
  end
end
