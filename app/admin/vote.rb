# frozen_string_literal: true

ActiveAdmin.register Vote do
  menu false

  config.batch_actions = true
  config.per_page = 100
  config.paginate = true

  actions :index, :show

  filter :user_id
  filter :subject_id, label: 'Subject ID'
  filter :subject_type, as: :select, collection: Vote::SUBJECT_TYPES.sort
  filter :user_role, as: :select, collection: User.roles
  filter :user_commented, label: 'user commented', as: :boolean
  filter :user_posted_or_made, label: 'hunter/maker', as: :boolean
  filter :created_at, as: :date_range, label: 'Voted On'
  filter :credible
  filter :sandboxed

  controller do
    def scoped_collection
      Vote.preload(:subject).includes(:check_results, user: :subscriber)
    end
  end

  batch_action :mark_votes_as_spam, confirm: 'This will mark the vote as sandboxed & non-credible. Additionally the user will be marked as potential spammer' do |ids|
    batch_action_collection.find(ids).each do |vote|
      SpamChecks.mark_vote_as_spam(
        vote: vote,
        handled_by: current_user,
        reason: 'bulk marking from admin votes',
      )
    end

    redirect_to request.referer || admin_votes_path
  end

  batch_action :mark_users_as_spammer, confirm: 'This will mark the user as a spammer & trash all the user activities(can be restored).' do |ids|
    batch_action_collection.find(ids).each do |vote|
      SpamChecks.mark_user_as_spammer(
        user: vote.user,
        handled_by: current_user,
        activity: vote,
        reason: 'bulk marking from admin votes',
      )
    end

    redirect_to request.referer || admin_votes_path
  end

  order_by(:registered_at) do |order_clause|
    if order_clause.order == 'desc'
      'users.created_at DESC'
    else
      'users.created_at ASC'
    end
  end

  order_by(:username) do |order_clause|
    if order_clause.order == 'desc'
      'users.username DESC'
    else
      'users.username ASC'
    end
  end

  order_by(:email) do |order_clause|
    if order_clause.order == 'desc'
      'notifications_subscribers.email DESC'
    else
      'notifications_subscribers.email ASC'
    end
  end

  order_by(:twitter) do |order_clause|
    if order_clause.order == 'desc'
      'users.twitter_username DESC'
    else
      'users.twitter_username ASC'
    end
  end

  index do
    selectable_column
    column :id do |vote|
      link_to vote.id, admin_vote_path(vote)
    end
    column 'Voted At', sortable: 'created_at', &:created_at
    column :subject
    column 'Subject Votes' do |vote|
      link_to 'View All', admin_votes_path(q: { subject_id_equals: vote.subject.id, subject_type_eq: vote.subject.class.name })
    end

    column :avatar do |vote|
      user_image(vote.user, size: 45)
    end

    column :user

    column 'Total Votes' do |vote|
      link_to vote.user.votes.count, admin_votes_path(q: { user_id_equals: vote.user_id })
    end

    column 'Total Comments' do |vote|
      vote.user.comments_count
    end

    column 'Hunter/Maker' do |vote|
      vote.user.posts_count > 0 || vote.user.product_makers_count > 0
    end

    column :role do |vote|
      vote.user.role
    end

    column :username, sortable: true do |vote|
      vote.user.username
    end

    column :email, sortable: true do |vote|
      vote.user.email
    end

    column :registered_at, sortable: true do |vote|
      vote.user.created_at
    end

    column :twitter, sortable: true do |vote|
      link_to vote.user.twitter_username, NormalizeTwitter.url(vote.user.twitter_username), target: :blank if vote.user.twitter_username?
    end

    column :producthunt_profile do |vote|
      link_to 'View', profile_path(vote.user)
    end

    column :score do |vote|
      span title: Voting::Checks.explain_vote_ring_score(vote) do
        Voting::Checks.vote_ring_score(vote)
      end
    end

    column :credible
    column :sandboxed
  end
end
