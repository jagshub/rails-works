# frozen_string_literal: true

ActiveAdmin.register_page 'Newsletter Counter Stats' do
  menu false

  controller do
    def index
      @newsletter = Newsletter.find params[:id]
    end
  end

  content do
    div class: 'attributes_table' do
      table do
        tr class: 'row' do
          th 'Send start'
          th 'Send stop'
          th 'Job fan-out count'
          th 'Jobs enqueued'
          th 'Jobs started'
          th 'Jobs missing'
          th 'Jobs sending'
          th 'Jobs send'
          th 'Jobs skip'
          th 'Notifications created'
          th 'Notifications delivered'
        end

        tr do
          td do
            Newsletter::Counters.fetch_start_fan_out(newsletter)
          end
          td do
            Newsletter::Counters.fetch_stop_fan_out(newsletter)
          end
          td do
            Newsletter::Counters.count(newsletter, 'fan_out')
          end
          td do
            Newsletter::Counters.count(newsletter, 'job_enqueue')
          end
          td do
            Newsletter::Counters.count(newsletter, 'start')
          end
          td do
            Newsletter::Counters.count(newsletter, 'missing')
          end
          td do
            Newsletter::Counters.count(newsletter, 'sending')
          end
          td do
            Newsletter::Counters.count(newsletter, 'send')
          end
          td do
            Newsletter::Counters.count(newsletter, 'skip')
          end
          td do
            NotificationLog.where(kind: NotificationLog.kinds[:newsletter], notifyable_id: newsletter.id, notifyable_type: newsletter.class.name).count
          end
          td do
            NotificationLog.joins(:events).where(kind: NotificationLog.kinds[:newsletter], notifyable_id: newsletter.id, notifyable_type: newsletter.class.name).count
          end
        end
      end
    end
  end

  sidebar 'Newsletter Details' do
    attributes_table_for newsletter do
      row :id
      row :subject
      row :status
      row :kind
      row :date
    end
  end
end
