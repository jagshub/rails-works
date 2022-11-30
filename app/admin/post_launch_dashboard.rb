# frozen_string_literal: true

ActiveAdmin.register_page 'Post Launch Dashboard' do
  menu false

  action_item :export_emails do
    link_to(
      'Emails (CSV)',
      admin_post_launch_dashboard_email_csv_path(id: post.id),
    )
  end

  action_item :export do
    link_to 'Export (CSV)', admin_post_launch_dashboard_csv_path(id: post.id)
  end

  action_item :refresh do
    link_to(
      'Refresh Data',
      admin_post_launch_dashboard_refresh_path(id: post.id),
      method: :post,
    )
  end

  action_item :refresh_hard do
    link_to(
      'Refresh Data (Hard)',
      admin_post_launch_dashboard_refresh_path(id: post.id, hard: true),
      data: { confirm: 'This will reset clearbit profiles. Are you sure?' },
      method: :post,
    )
  end

  controller do
    def index
      @post = Post.friendly.find params[:id]
      @report = Posts.generate_launch_report @post
    end
  end

  content do
    h2 'Credible Voter Demographic Summary'
    div do
      report.summary.each do |header, rows|
        h4 header.humanize
        table do
          thead do
            tr do
              th 'Value'
              th 'Count'
            end
          end
          tbody do
            rows.each do |row|
              tr do
                td row[0]
                td row[1]
              end
            end
          end
        end
      end
    end
  end

  sidebar 'Summary' do
    table do
      tr do
        td { strong 'Total votes' }
        td { report.post.votes_count }
      end
      tr do
        td { strong 'Total credible votes' }
        td { report.post.credible_votes_count }
      end
    end
  end

  page_action :csv, method: :get do
    post = Post.friendly.find params[:id]
    report = Posts.generate_launch_report(post)

    send_data(*report.as_csv_data)
  end

  page_action :email_csv, method: :get do
    post = Post.friendly.find params[:id]
    report = Posts.generate_launch_report(post)

    send_data(*report.as_email_csv_data)
  end

  page_action :refresh, method: :post do
    hard_refresh = params[:hard].presence || false
    post = Post.friendly.find params[:id]
    Posts::Jobs::EnrichVoters.perform_later(
      post: post,
      hard_refresh: hard_refresh,
    )

    redirect_to(
      admin_post_launch_dashboard_path(post),
      notice: 'Clearbit import started, this may take some time.',
    )
  end
end
