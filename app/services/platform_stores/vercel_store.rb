# frozen_string_literal: true

module PlatformStores
  class VercelStore < Store.new(
    enum: 33,
    name: 'Vercel',
    key: :vercel,
    os: 'Web',
    matchers: [
      /^[\w\d-]+\.vercel\.app/,
      /^[\w\d-]+\.now\.sh/,
    ],
  )
  end
end
