# frozen_string_literal: true

ActiveAdmin.register Post do
  menu label: 'Posts'

  config.batch_actions = true

  csv do
    column('Status') {}
    column :id
    column :name
    column :tagline
    column :votes_count
    column :slug
    column :link_visits
    column :link_unique_visits
    column :score_multiplier
    column :featured_at
    column('Url') { |post| post_url(post) }
    column 'Topics' do |post|
      post.topics.map(&:name).join(', ')
    end
    (0..15).each do |no|
      column "Maker ##{ no + 1 } Name" do |post|
        post.makers[no]&.name
      end
      column "Maker ##{ no + 1 } Email" do |post|
        post.makers[no]&.email
      end
    end
  end

  actions :all, except: %i(new create)

  permit_params(*Admin::PostForm.attribute_names, *Product::SOCIAL_LINKS)

  scope(:all, default: true)
  scope(:featured, &:featured)
  scope(:unfeatured) { |scope| scope.where(featured_at: nil) }
  scope(:scheduled_for_featuring) { |scope| scope.where(Post.arel_table[:featured_at].gt(Time.current)) }
  scope(:scheduled_without_featuring) { |scope| scope.where(featured_at: nil).where(Post.arel_table[:scheduled_at].gt(Time.current)) }
  scope(:scheduled) { |scope| scope.where('featured_at > :time OR scheduled_at > :time', time: Time.current) }
  scope(:trashed) { |scope| scope.where.not(trashed_at: nil) }

  scope 'Golden Kitty', if: proc { params[:golden_kitty_category].present? } do |posts|
    ids = ::GoldenKitty::Nominee.where(golden_kitty_category_id: params[:golden_kitty_category]).pluck(:post_id).uniq

    posts.where(id: ids)
  end

  filter :user_username, as: :string
  filter :user_id, as: :numeric, label: 'User ID'
  filter :name
  filter :tagline
  filter :created_at
  filter :updated_at
  filter :featured_at
  filter :clean_url
  filter :accepted_duplicate
  filter :exclude_from_ranking

  batch_action :add_finalist, if: proc { params[:scope] == 'golden_kitty' && params[:golden_kitty_category].present? }, form: { category: :text } do |ids, inputs|
    ids.each { |id| ::GoldenKitty::Finalist.create!(post_id: id, golden_kitty_category_id: inputs[:category]) }

    redirect_to admin_golden_kitty_finalists_url
  end

  batch_action :trash do |ids|
    Post.where(id: ids).map(&:trash)

    redirect_to admin_posts_url
  end

  batch_action :mark_as_spam do |ids|
    Post.where(id: ids).find_each do |post|
      Spam::MarkHarmfulEntity.call(
        user: post.user,
        entity: post,
        current_user: current_user,
        remarks: 'Bulk action perform from admin.',
      )
    end

    redirect_to admin_posts_url
  end

  index pagination_total: false do
    selectable_column

    column :id
    column :name do |post|
      link_to post.name, admin_post_path(post)
    end
    column :tagline
    column :user
    column 'Makers' do |post|
      safe_join(post.makers.map { |m| link_to m.name, profile_path(m) }, ', ') if post.makers.any?
    end
    column 'Url' do |post|
      link_to post.url.truncate(40), post.url
    end
    column 'Repost', :accepted_duplicate
    column 'Comments', sortable: :comments_count, class: 'count' do |post|
      link_to post.comments_count, admin_commentxes_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
    end

    column 'Votes', sortable: :votes_count, class: 'count' do |post|
      link_to "#{ post.votes_count } (#{ post.credible_votes_count })", admin_votes_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
    end

    if params[:scope] == 'golden_kitty'
      column :credible_votes_count
      column 'Finalist' do |post|
        post.golden_kitty_finalist.where(golden_kitty_category_id: params[:golden_kitty_category]).pluck(:id).present?
      end
    end

    column 'Visits', class: 'count' do |post|
      "#{ post.link_visits } (#{ post.link_unique_visits })"
    end
    column 'Multi', :score_multiplier
    column 'State' do |post|
      post.state.to_s.titlecase
    end
    column 'Date', sortable: :scheduled_at do |post|
      post.featured_at || post.scheduled_at
    end
    column 'Edit' do |post|
      link_to 'Edit', edit_admin_post_url(post)
    end
    column 'In Site' do |post|
      link_to 'In Site', post_path(post)
    end
    column '' do |post|
      link_to 'Dashboard', admin_post_launch_dashboard_path(id: post.id)
    end
  end

  show do
    default_main_content

    attributes_table do
      row :id
      row 'Product', &:new_product
      row :votes_count
      row :credible_votes_count
      row :comments_count
      row :alternatives_count
      row :link_visits
      row :link_unique_visits
      row :exclude_from_ranking
      row :votes do |post|
        link_to 'View all votes', admin_votes_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
      end
      row :comments do |post|
        link_to 'View all comments', admin_commentxes_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
      end
      row :reviews do |post|
        link_to 'View all reviews', admin_reviews_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
      end
    end

    panel 'Links' do
      table_for post.links do
        column :id do |link|
          link_to link.id, admin_legacy_product_link_path(link)
        end
        column 'Store Name', &:store_name
        column 'Store OS', &:os
        column :url
        column :primary_link
      end
    end

    panel 'Makers' do
      table_for post.product_makers do
        column 'user' do |product_maker|
          product_maker.user.name
        end

        column 'Delete' do |product_maker|
          link_to 'Delete', admin_product_maker_path(product_maker), method: :delete
        end
      end
    end

    panel 'Moderation Log' do
      table_for post.moderation_logs.with_preloads.order(created_at: :desc) do
        column 'Action', :message
        column :reason
        column :moderator
        column :created_at
      end
    end

    panel 'Reviews with comments' do
      table_for post.reviews.with_comment.includes(:user) do
        column :user

        column :sentiment
        column :rating
        column :comment do |review|
          review.comment.body.truncate(50)
        end
        column :votes_count
        column :credible_votes_count
        column :created_at

        column 'Edit' do |review|
          link_to 'Edit', edit_admin_review_url(review.id)
        end
        column 'Delete' do |review|
          link_to 'Delete', admin_review_url(review.id), method: :delete
        end
        column 'Show' do |review|
          link_to 'Show', admin_review_url(review.id)
        end
      end
    end

    panel 'Post Media' do
      table_for post.media.includes(:user) do
        column do |media|
          image_tag media.image_url(width: 130, height: 95)
        end
        column :media_type
        column :original_width
        column :original_height
        column :priority
        column :user
        column :created_at

        column 'Edit' do |media|
          link_to 'Edit', edit_admin_media_url(media)
        end
        column 'Delete' do |media|
          link_to 'Delete', admin_media_url(media), method: :delete
        end
      end
    end

    panel 'Launch Day Insight Reports' do
      table_for post.launch_day_reports do
        column :id
        column :created_at
        column 'Download' do |report|
          link_to(
            'Download',
            download_insights_admin_post_url(post, report_id: report.id),
            target: '_blank', rel: 'noopener',
          )
        end
      end
    end

    attributes_table do
      row :votes do |post|
        link_to 'View all votes', admin_votes_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
      end
      row :comments do |post|
        link_to 'View all comments', admin_commentxes_path(q: { subject_id_equals: post.id, subject_type_eq: post.class.name })
      end
    end

    if post.new_product.present?
      panel 'Related Products' do
        table_for post.new_product.product_associations.by_date.includes(:associated_product) do
          column :id
          column :relationship
          column :associated_product
          column :created_at
        end
      end
    end

    render 'admin/shared/audits'
  end

  member_action :trash, method: :put do
    resource.trash
    redirect_to resource_path, notice: "Post has been trashed, can no longer be seen anywhere on the site. Click 'Restore Post' to undo."
  end

  member_action :restore, method: :put do
    resource.restore
    redirect_to resource_path, notice: 'Post has been restored!'
  end

  member_action :insights, method: :post do
    Posts::GenerateLaunchDayInsightsReportWorker.perform_later(resource.id)
    redirect_to resource_path, notice: 'Insights report has been queued for generation.'
  end

  member_action :download_insights, method: :get do
    report = resource.launch_day_reports.find(params[:report_id])
    redirect_to Posts::LaunchDay::Reports::S3.download_url(report)
  end

  collection_action :search_posts_without_products, method: :get

  action_item 'View in Site', only: %i(edit show) do
    link_to 'View in Site', post_path(resource)
  end

  action_item 'Trash Post', only: %i(edit show) do
    post = Post.find_by_slug!(params[:id])
    if post.trashed?
      link_to 'Restore Post', restore_admin_post_url(post), method: :put, confirm: 'Are you sure?'
    else
      link_to 'Trash Post (Can be restored)', trash_admin_post_url(post), method: :put, confirm: 'Are you sure?'
    end
  end

  action_item 'insights', method: :post, only: :show do
    link_to 'Generate Insights Report', insights_admin_post_url(resource), method: :post
  end

  controller do
    defaults finder: :find_by_slug!

    def scoped_collection
      Post.includes(:user, :makers, :topics, :golden_kitty_finalist)
    end

    def edit
      @post = Admin::PostForm.new current_user, Post.find_by_slug!(params[:id])
    end

    def update
      @post = Admin::PostForm.new current_user, Post.find_by_slug!(params[:id])
      @post.publish(permitted_params[:post])

      redirect_to post_path @post
    end

    # NOTE(DZ): Specifically for the associate_posts menu in admin products
    def search_posts_without_products
      query = params.dig(:q, :groupings, '0', :query_contains)
      scope =
        Post
        .not_trashed
        .left_joins(:product_association)
        .where(product_post_associations: { id: nil })
        .order(credible_votes_count: :desc)
        .limit(10)

      scope = if /^\d+$/.match?(query)
                scope.where(id: query)
              else
                scope.where('name ilike :query OR '\
                                    'slug ilike :query', query: LikeMatch.by_words(query))
              end

      render json: {
        posts: scope.map do |post|
          post.as_json.merge(
            admin_search_display_name: post.admin_search_display_name,
          )
        end,
      }
    end
  end

  form do |f|
    f.inputs 'Post' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :name
      f.input :slug, as: :string, hint: 'This is the name in the URL that directs to this product.<br /> If you\'re updating this property <b>understand that any existing links with the old slug will no longer direct to this product</b>.'.html_safe
      f.input :tagline
      f.input :url, as: :string
      f.input :promo_text, as: :string
      f.input :promo_code, as: :string
      f.input :promo_expire_at, as: :string
      f.input :exclude_from_ranking, as: :boolean
      f.input :accepted_duplicate, as: :boolean, hint: 'Ignore existing posts with the same URL (use only if needed)'
      f.input :score_multiplier, hint: 'Multiplier for ranking algorithm, don\'t change unless you know what you\'re doing'
      f.input :featured_at, as: :datetime_picker, hint: 'If a date is here, product will go to the homepage. Leave empty (press x) to hide from homepage and search. Provide a future date for scheduling a post'
      f.input :scheduled_at, as: :datetime_picker, hint: 'Date from which post will be visible in the website'
      f.input :disabled_when_scheduled, as: :boolean, label: 'Disable voting, reviews and sharing for scheduled post', hint: 'Ignored when post scheduled date passes.'
      f.input :product_state, as: :select, collection: Post.product_states.keys.to_a, include_blank: false, hint: 'Products that are not longer online will get a cute ghost. Use in moderation ;)'

      if f.object.product.present?
        Product::SOCIAL_LINKS.each do |link_name|
          f.input link_name, as: :string
        end
      else
        li do
          f.label 'Social links'
          strong 'No product is set for this post, link or create one in order to set social links'
        end
      end
    end

    f.actions
  end
end
