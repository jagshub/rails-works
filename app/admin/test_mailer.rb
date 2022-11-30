# frozen_string_literal: true

ActiveAdmin.register_page 'Test Mailer' do
  menu label: 'Test mailer', parent: 'Others'

  page_action :deliver, method: :post do
    to = params[:to]
    subject = params[:subject]
    body = params[:body]
    delivery_method = params[:delivery_method]

    if to.blank? || subject.blank? || body.blank? || delivery_method.blank?
      redirect_to admin_test_mailer_path, alert: 'Enter all values'
    else
      TestMailer.test(
        to: to,
        subject: subject,
        body: body,
        delivery_method: delivery_method,
      ).deliver_now

      redirect_to admin_root_path, notice: "Test email sent to #{ to }"
    end
  end

  page_action :send_mailjet_test do
    payload = { test_id: SecureRandom.uuid }
    TestMailer.mailjet_payload_test(current_user, payload: payload).deliver_now

    redirect_back(
      fallback_location: admin_root_path,
      notice: "Test email sent to #{ current_user.email }",
    )
  end

  content do
    form(method: :post, action: admin_test_mailer_deliver_path) do
      input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s

      div do
        label do
          div 'Email'
          input name: 'to', type: :email, value: current_user.email
        end
      end

      div do
        label do
          div 'Subject'
          input name: 'subject', type: :text
        end
      end

      div do
        label do
          div 'Body'
          textarea name: 'body'
        end
      end

      div do
        label do
          div 'Delivery method'
          select name: 'delivery_method' do
            TestMailer::DELIVERY_METHODS.keys.each do |delivery_method|
              option selected: delivery_method == :default do
                delivery_method
              end
            end
          end
        end
      end

      input type: 'submit', value: 'Send'
    end
  end
end
