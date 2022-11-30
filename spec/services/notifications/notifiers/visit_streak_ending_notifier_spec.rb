# frozen_string_literal: true

require 'spec_helper'
require 'services/notifications/notifiers/shared_examples'

describe Notifications::Notifiers::VisitStreakEndingNotifier do
  include_examples 'mobile_push channel', :visit_streak_ending_notification_log

  describe '.channels' do
    it 'sends push' do
      expect(described_class.channels).to have_key(:mobile_push)
    end
  end

  describe '.push_text_oneliner and .push_text_body' do
    it 'returns the correct push notification text' do
      notification = create :visit_streak_ending_notification_log
      user_streak_reminder = notification.notifyable

      expected_text = %(Your #{ ::UserVisitStreak.visit_streak_duration(user_streak_reminder.user) } day streak is expiring soon,\n don't loose it now 🔥)
      expect(described_class.push_text_oneliner(notification)).to match expected_text
      expect(described_class.push_text_body(notification)).to match expected_text
    end
  end

  describe '.thumbnail_url' do
    it 'returns shows the avatar url of the user' do
      some_url = double('Some::PictureUrl')
      notification = create :visit_streak_ending_notification_log

      allow(Users::Avatar).to receive(:url_for_user).and_return(some_url)

      expect(described_class.thumbnail_url(notification)).to eq some_url

      expect(Users::Avatar).to have_received(:url_for_user).with(notification.notifyable.user, size: 80)
    end
  end

  context 'integration', active_job: :inline do
    let(:subscriber) { create :subscriber, :with_user, :with_all_tokens }

    it 'triggers mobile push sending using mobile device token' do
      stub_channel(Notifications::Channels::MobilePush)
      expected_heading = "🚨 Don't loose your streak"
      user_streak_reminder = create :user_visit_streak_reminder, user: subscriber.user

      create(:mobile_device, user: subscriber.user, one_signal_player_id: 'OSP1')
      subscriber_user_devices = Mobile::Device.enabled_push_for(user_id: subscriber.user.id)
      subscriber_user_player_ids = subscriber_user_devices.map(&:one_signal_player_id) if subscriber_user_devices.present?

      Notifications.notify_about(kind: 'visit_streak_ending', object: user_streak_reminder)

      expect_channel_to_have_received(Notifications::Channels::MobilePush, service_call_with: [
                                        a_hash_including(
                                          include_player_ids: subscriber_user_player_ids,
                                          headings: { en: expected_heading },
                                          data: a_hash_including(
                                            route: 'http://www.producthunt.com/streak_pop',
                                          ),
                                        ),
                                      ])
    end
  end
end
