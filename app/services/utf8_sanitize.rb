# frozen_string_literal: true

# NOTE(rstankov): Browsers send params in wrong encoding, which causes `invalid byte sequence in UTF-8`
#    More info: https://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences
module Utf8Sanitize
  extend self

  def call(string)
    return if string.nil?

    string.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end
end
