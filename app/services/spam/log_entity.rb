# frozen_string_literal: true

module Spam::LogEntity
  extend self

  def call(data)
    entity = data[:entity]
    log = get_log_data data

    case entity
    when Comment then set_comment_log log, entity
    when Post then set_post_log log, entity
    when User then set_user_log log, entity
    when Vote then set_vote_log log, entity
    else raise "Invalid entity - #{ entity.class.name } #{ entity.id }"
    end

    Spam::Log.create! log
  rescue ActiveRecord::InvalidForeignKey
    nil
  end

  private

  def get_log_data(data)
    current_user = data[:current_user] || '__KITTY_BOT__'

    log = {
      user: data[:user],
      action: data[:action],
      remarks: data[:remarks],
      kind: data[:kind] || :manual,
      parent_log_id: data[:parent_log_id],
      level: data[:level] || :questionable,
      content_type: data[:entity].class.to_s.downcase,
      more_information: {
        marked_by: current_user.instance_of?(User) ? current_user.username : current_user,
      },
    }

    log[:more_information].merge!(data[:more_information]) if data[:more_information]

    log
  end

  def set_comment_log(log, entity)
    log[:content] = entity.body
    log[:more_information].merge!(
      created_at: entity.created_at,
      subject_type: entity.subject_type,
      subject_id: entity.subject_id,
    )
  end

  def set_post_log(log, entity)
    log[:content] = entity.name
    log[:more_information].merge!(
      state: entity.state.to_s,
      link_unique_visits: entity.link_unique_visits,
      slug: entity.slug,
      description_html: entity.description_html,
      tagline: entity.tagline,
    )
  end

  def set_user_log(log, entity)
    log[:content] = entity.name
    log[:more_information].merge!(
      username: entity.username,
      twitter_username: entity.twitter_username,
    )
  end

  def set_vote_log(log, entity)
    log[:content] = entity.id
    log[:more_information].merge!(
      subject_type: entity.subject_type,
      subject_id: entity.subject_id,
    )
  end
end
