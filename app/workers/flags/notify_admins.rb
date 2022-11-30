# frozen_string_literal: true

# NOTE(DZ): Remove when flag queue in mod tools is finished
class Flags::NotifyAdmins < ApplicationJob
  include ActiveJobHandleMailjetErrors
  include ActiveJobHandleNetworkErrors
  include ActiveJobHandleDeserializationError

  def perform(flag)
    if flag.subject_deleted?
      delete_flag(flag)
    else
      notify_about_flag(flag)
    end
  end

  private

  def delete_flag(flag)
    flag.destroy!
  end

  def name(flag)
    subject = flag.subject

    case subject
    when Comment
      "Comment by #{ subject.user.name }"
    when ProductRequest
      subject.title
    when Recommendation
      "Recommendation by #{ subject.user.name }"
    when Review
      "#{ subject.user.name }'s review of #{ (subject.product || subject.post).name }"
    when Post, Product
      subject.name
    when User
      "User #{ subject.name }"
    when Team::Invite
      "Invite from #{ subject.referrer.name } to #{ subject.user.name }"
    when Team::Request
      "Team Request from #{ subject.user.name } to #{ subject.product.name }"
    else
      raise ArgumentError, "Unknown subject type #{ subject.class }"
    end
  end

  def notify_about_flag(flag)
    attachment = {
      title: "#{ name(flag) } was flagged",
      title_link: Routes.subject_url(flag.subject),
      fields: [
        {
          title: 'Reason',
          value: flag.reason,
        },
      ],
    }

    if flag.user
      attachment[:author_name] = "#{ flag.user.name } (@#{ flag.user.username })"
      attachment[:author_link] = Routes.profile_url(flag.user)
      attachment[:author_icon] = Users::Avatar.url_for_user(flag.user)
    end

    SlackNotify.call(
      channel: :flagged,
      attachment: attachment,
      deliver_now: true,
    )
  end
end
