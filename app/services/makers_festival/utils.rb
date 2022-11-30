# frozen_string_literal: true

module MakersFestival::Utils
  extend self

  CODA = 'coda'
  API_V2 = 'product-hunt-api-2-0'
  SNAPCHAT = 'snapchat'
  WFH = 'wfh'

  DISCUSSION_MAINTAINERS = {
    CODA => [
      '79390',
      '1051110',
    ],
    API_V2 => ['86915'],
    SNAPCHAT => ['726999'],
    WFH => ['726999'],
  }.freeze

  PHASES = %i(registration registration_ended submission submission_ended voting voting_ended result).freeze

  PHASE_TITLES = {
    registration: '📣 Announcement & Registration opens',
    submission: '⏰ Submissions Opens',
    submission_ended: '👋 Submission Closes',
    voting: '🔼 Voting Opens',
    voting_ended: '🥁 Voting Closes',
    result: '🏅 Winners Announced!',
  }.freeze

  def period(edition)
    today = Time.zone.now

    PHASES.select do |phase|
      edition[phase] <= today
    end.last || PHASES.first
  end

  def timeline_for_festival(edition)
    PHASE_TITLES.keys.map do |phase|
      date = edition[phase]

      {
        title: PHASE_TITLES[phase],
        phase: phase,
        date: date.strftime('%Y-%m-%d'),
        dateText: "#{ date.strftime('%B') } #{ date.mday.ordinalize }",
      }
    end
  end
end
