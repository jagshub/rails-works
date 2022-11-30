# frozen_string_literal: true

class Graph::Resolvers::Maker::Groups::HasMembershipResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def self.build(state: nil)
    resolver_class = Class.new(self)
    resolver_class.define_method(:state) { state }

    resolver_class
  end

  def resolve
    return false if current_user.blank?

    MakerGroupMemberLoader.for(current_user, state).load(object)
  end

  class MakerGroupMemberLoader < GraphQL::Batch::Loader
    def initialize(user, state)
      @user = user
      @state = state
    end

    def perform(groups)
      maker_group_ids = MakerGroupMember.where(group: groups, state: @state, user: @user).pluck(:maker_group_id)

      groups.each do |group|
        fulfill group, maker_group_ids.include?(group.id)
      end
    end
  end

  private

  def state
    raise NotImplementedError
  end
end
