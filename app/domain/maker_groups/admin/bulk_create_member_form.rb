# frozen_string_literal: true

class MakerGroups::Admin::BulkCreateMemberForm < Admin::BaseForm
  model :group, save: false

  main_model :group, MakerGroup

  attr_accessor :user_ids
  attr_reader :users_created

  delegate_missing_to :group

  def initialize(group = MakerGroup.new)
    @users_created = 0
    @group = group
  end

  def update(params)
    params[:user_ids].split(',').each do |user_id_or_username|
      id = user_id_or_username.strip
      user = User.where(id: id).or(User.where(username: id)).first

      result = group.members.create(
        user_id: user.id,
        state: :accepted,
        role: 0,
      )

      @users_created += 1 if result.persisted?
    end
  end
end
