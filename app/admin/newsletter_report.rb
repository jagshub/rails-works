# frozen_string_literal: true

ActiveAdmin.register_page 'Newsletter Report' do
  menu false

  controller do
    def index
      @newsletter_report = Metrics::Newsletter::EventsReport.data params[:id]
    end
  end

  content do
    div class: 'attributes_table' do
      table do
        tr class: 'row' do
          th 'Url'
          th 'Section'
          th 'Clicks'
        end

        {
          'Primary Featured' => newsletter_report.primary.first,
          'Primary Read More' => newsletter_report.primary_read_more.first,
          'Secondary Featured' => newsletter_report.secondary.first,
          'Tertiary Featured' => newsletter_report.tertiary.first,
          'Jobs' => newsletter_report.jobs.first,
          'Upcoming' => newsletter_report.upcoming.first,
          'Top Hunts' => newsletter_report.top_posts.first,
        }.each do |section, report|
          report&.each do |stats|
            tr do
              td do
                stats[:url]
              end
              td do
                section
              end
              td do
                number_with_delimiter(stats[:clicks].split(' ')&.first)
              end
            end
          end
        end
      end
    end
  end

  sidebar 'Metrics' do
    div class: 'attributes_table' do
      table do
        tr class: 'row' do
          th 'Sent'
          td class: 'count' do
            number_with_delimiter(newsletter_report.sent_count)
          end
          td class: 'count' do
            ''
          end
        end
        tr class: 'row' do
          th 'Open'
          td class: 'count' do
            number_with_delimiter(newsletter_report.open_count)
          end
          td class: 'count' do
            number_to_percentage((newsletter_report.open_count.to_f / newsletter_report.sent_count) * 100, precision: 0)
          end
        end
        tr class: 'row' do
          th 'Click'
          td class: 'count' do
            number_with_delimiter(newsletter_report.total_clicks)
          end
          td class: 'count' do
            number_to_percentage((newsletter_report.total_clicks.to_f / newsletter_report.open_count) * 100, precision: 0)
          end
        end
      end
    end
  end

  sidebar 'Click Metrics' do
    div class: 'attributes_table' do
      table do
        tr class: 'row' do
          th 'Total'
          td class: 'count' do
            number_with_delimiter(newsletter_report.total_clicks)
          end
          td class: 'count' do
            ''
          end
        end
        tr class: 'row' do
          th 'Unique'
          td class: 'count' do
            number_with_delimiter(newsletter_report.unique_clicks)
          end
          td class: 'count' do
            ''
          end
        end

        {
          'View Online' => newsletter_report.view_online.second,
          'Primary' => newsletter_report.primary.second,
          'Secondary' => newsletter_report.secondary.second,
          'Jobs' => newsletter_report.jobs.second,
          'Upcoming' => newsletter_report.upcoming.second,
          'Top Post' => newsletter_report.top_posts.second,
          'Unsubscribe' => newsletter_report.subscription_events.first,
          'Switch to Weekly' => newsletter_report.subscription_events.second,
        }.each do |metric, stats|
          tr class: 'row' do
            th metric.to_s
            td class: 'count' do
              stats ? number_with_delimiter(stats.split(' ').first) : 0
            end
            td class: 'count' do
              stats ? stats.split(' ').last.tr('()', '') : 0
            end
          end
        end
      end
    end
  end

  sidebar 'Newsletter Details' do
    attributes_table_for newsletter_report.newsletter do
      row :id
      row :subject
      row :status
      row :kind
      row :date
    end
  end
end
