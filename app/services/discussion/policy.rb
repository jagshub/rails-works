# frozen_string_literal: true

module Discussion::Policy
  extend KittyPolicy
  extend self

  can %i(create), Discussion::Thread do |user, _|
    user.verified_legit_user? && !user.company?
  end

  can %i(update), Discussion::Thread do |user, thread|
    user.admin? || thread.user_id == user.id
  end

  can %i(moderate), Discussion::Thread do |user, _thread|
    user.admin?
  end

  can %i(destroy), Discussion::Thread do |user, thread|
    user.admin? || thread.user_id == user.id
  end
end
