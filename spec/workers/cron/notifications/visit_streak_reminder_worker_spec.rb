# frozen_string_literal: true

require 'spec_helper'

describe Cron::Notifications::VisitStreakReminderWorker do
  describe '#perform' do
    before do
      Features.enable_for_all('ph_visit_streak_reminder')
      allow(Notifications::FanOutWorker).to receive(:set).and_return(Notifications::FanOutWorker)
      allow(Notifications::FanOutWorker).to receive(:perform_later)
    end

    it "returns successfully if the user doesn't have visit streaks" do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 0
      expect(::UserVisitStreak.current_streak_ends_in(user)).to be_nil

      described_class.perform_now
      expect(Notifications::FanOutWorker).not_to have_received(:perform_later)
    end

    it 'does not send notification if the user has not reached >=4 day streak' do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user
      create :visit_streak, user: user, started_at: 3.days.ago, duration: 3, last_visit_at: 40.hours.ago, created_at: 1.week.ago

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 3
      expect(::UserVisitStreak.current_streak_ends_in(user)).to eq 8

      described_class.perform_now
      expect(Notifications::FanOutWorker).not_to have_received(:perform_later)
    end

    it 'does not send notification if the user has >=4 day streak but streak does not expire in next 8 hours' do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user
      create :visit_streak, user: user, started_at: 4.days.ago, duration: 4, last_visit_at: 30.hours.ago, created_at: 1.week.ago

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 4
      expect(::UserVisitStreak.current_streak_ends_in(user)).to eq 18

      described_class.perform_now
      expect(Notifications::FanOutWorker).not_to have_received(:perform_later)
    end

    it 'does not send notification when feature is disabled ' do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user
      create :visit_streak, user: user, started_at: 7.days.ago, duration: 7, last_visit_at: 40.hours.ago, created_at: 1.week.ago

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 7
      expect(::UserVisitStreak.current_streak_ends_in(user)).to eq 8

      Features.disable_for_all('ph_visit_streak_reminder')

      described_class.perform_now
      expect(Notifications::FanOutWorker).not_to have_received(:perform_later).with(kind: 'visit_streak_ending',
                                                                                    object: user.user_visit_streak_reminders.last)
    end

    it 'sends notification if the user has >=4 day streak and streak expires in next 8 hours' do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user
      create :visit_streak, user: user, started_at: 4.days.ago, duration: 4, last_visit_at: 40.hours.ago, created_at: 1.week.ago

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 4
      expect(::UserVisitStreak.current_streak_ends_in(user)).to eq 8

      described_class.perform_now
      expect(Notifications::FanOutWorker).to have_received(:perform_later).with(kind: 'visit_streak_ending',
                                                                                object: user.user_visit_streak_reminders.last)
    end

    it 'does not sends second notification if notification was sent in last 8 hours' do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user
      create :visit_streak, user: user, started_at: 7.days.ago, duration: 7, last_visit_at: 40.hours.ago, created_at: 1.week.ago

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 7
      expect(::UserVisitStreak.current_streak_ends_in(user)).to eq 8

      described_class.perform_now
      described_class.perform_now

      expect(Notifications::FanOutWorker).to have_received(:perform_later).once
    end

    it 're-sends notification when last notification was sent more than 8 hours ago' do
      subscriber = create :subscriber, :with_user, :with_all_tokens
      user = subscriber.user
      create :visit_streak, user: user, started_at: 7.days.ago, duration: 7, last_visit_at: 40.hours.ago, created_at: 1.week.ago

      expect(::UserVisitStreak.visit_streak_duration(user)).to eq 7
      expect(::UserVisitStreak.current_streak_ends_in(user)).to eq 8

      described_class.perform_now
      reminder = UserVisitStreaks::Reminder.find_by_user_id(user.id)
      reminder.update!(created_at: 9.hours.ago)
      described_class.perform_now

      expect(Notifications::FanOutWorker).to have_received(:perform_later).twice
    end
  end
end
