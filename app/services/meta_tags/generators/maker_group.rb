# frozen_string_literal: true

class MetaTags::Generators::MakerGroup < MetaTags::Generator
  def canonical_url
    Routes.maker_group_welcome_url(group)
  end

  def creator
    '@producthunt'
  end

  def description
    group.tagline
  end

  def image
    return S3Helper.image_url('makers-wit-social.png') if group.name == 'Women in Tech'

    S3Helper.image_url('makers-social.png')
  end

  def title
    format('%s', group.name)
  end

  private

  def group
    @group ||= subject
  end
end
