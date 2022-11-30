# frozen_string_literal: true

FactoryBot.define do
  factory :visit_streak do
    association :user, factory: :credible_user
    started_at { 1.day.ago }
    last_visit_at { 1.day.ago }
    duration { 1 }

    trait :ended do
      started_at { 1.week.ago }
      ended_at { Time.zone.now }
      last_visit_at { Time.zone.now }
      duration { 7 }
    end
  end
end
