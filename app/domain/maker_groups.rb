# frozen_string_literal: true

module MakerGroups
  extend self

  def bulk_create_members_form
    MakerGroups::Admin::BulkCreateMemberForm
  end

  def find_group(beta, user)
    return MakerGroup.main if user.blank? || beta.blank?

    if beta == 'ios' && ApplicationPolicy.can?(user, :participate, :ios_beta)
      MakerGroup.ios_beta
    elsif beta == 'android' && ApplicationPolicy.can?(user, :participate, :android_beta)
      MakerGroup.android_beta
    else
      MakerGroup.main
    end
  end
end
