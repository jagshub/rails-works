# frozen_string_literal: true

class Twitter::Message
  TWEET_LENGTH = 280
  T_CO_LINK_PLACHOLDER = 'i' * 23
  URL_REGEX = %r{https?:\/\/\S+}.freeze

  attr_reader :chunks

  def initialize(chunks = [])
    @chunks = chunks
  end

  def add_mandatory(text, options = {})
    formatted_text = options.fetch(:leading_space, true) && !chunks.length.zero? ? " #{ text }" : text
    chunks << { text: formatted_text, priority: :mandatory } if options.fetch(:if, true)

    self
  end

  def add_optional(text, options = {})
    formatted_text = options.fetch(:leading_space, true) && !chunks.length.zero? ? " #{ text }" : text
    chunks << { text: formatted_text, priority: :optional } if options.fetch(:if, true)

    self
  end

  def ==(other)
    super unless other.is_a? String
    text == other
  end

  def to_s
    raise MessageTooLong if too_long?(text)

    text
  end

  private

  def text
    @text ||= chunks_to_text
  end

  def chunks_to_text
    accepted_chunks = chunks.map do |chunk|
      chunk[:text] if chunk[:priority] == :mandatory
    end

    chunks.each_with_index do |chunk, index|
      next unless chunk[:priority] == :optional
      next if too_long?(accepted_chunks.join('') + chunk[:text])

      accepted_chunks[index] = chunk[:text]
    end

    accepted_chunks.join('')
  end

  def too_long?(text)
    text.gsub(URL_REGEX, T_CO_LINK_PLACHOLDER).length > TWEET_LENGTH
  end

  class MessageTooLong < StandardError
  end
end
