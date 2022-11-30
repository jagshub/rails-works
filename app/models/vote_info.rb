# frozen_string_literal: true

# == Schema Information
#
# Table name: vote_infos
#
#  id                   :integer          not null, primary key
#  vote_id              :integer          not null
#  request_ip           :inet
#  first_referer        :text
#  oauth_application_id :integer
#  visit_duration       :integer
#  user_agent           :text
#  device_type          :text
#  os                   :text
#  browser              :text
#  country              :text
#
# Indexes
#
#  index_vote_infos_on_vote_id  (vote_id) UNIQUE
#

class VoteInfo < ApplicationRecord
  belongs_to :vote
  belongs_to :oauth_application, class_name: 'OAuth::Application', optional: true
end
