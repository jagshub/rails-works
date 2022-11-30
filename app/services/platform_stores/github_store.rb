# frozen_string_literal: true

module PlatformStores
  class GithubStore < Store.new(
    enum: 14,
    name: 'Github',
    key: :github,
    os: 'Web',
    matchers: [
      %r{^github.com(/[.\w\d-]+/[.\w\d-]+)}i,
      %r{^(gist|help|education|enterprise|docs)\.github.com/[/\w\d-]+}i,
      %r{^[\w\d-]+\.github.io/[.\w\d-]+}i,
    ],
  )
  end
end
