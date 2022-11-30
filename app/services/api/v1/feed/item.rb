# frozen_string_literal: true

class API::V1::Feed::Item
  attr_reader :id, :body, :sentence, :reference, :from_user, :seen, :timestamp

  alias seen? seen

  # Note (Mike Coutermarsh): the iOS uses these values to display an emoji on the notification page.
  #   To keep backward compatibility, we convert the new "verbs" to these old versions.
  #   See: https://github.com/producthunt/producthunt/pull/5410
  VERB_TO_LEGACY_BODY_MAPPING = {
    'comment' => 'mentioned you in a comment on',
    'upvote' => 'upvoted',
  }.freeze

  def initialize(options = {})
    @id = options[:id].to_i
    @body = VERB_TO_LEGACY_BODY_MAPPING[options[:body]] || 'posted'
    @sentence = ActionView::Base.full_sanitizer.sanitize(options[:sentence])
    @reference = options[:reference]
    @from_user = options[:from_user]
    @seen = options[:seen]
    @timestamp = options[:timestamp] ? Time.zone.at(options[:timestamp].to_i) : Time.current
  end
end
