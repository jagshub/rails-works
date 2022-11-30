# frozen_string_literal: true

ActiveAdmin.register_page 'GDPR Delete Email' do
  menu label: 'GDPR Delete Email', parent: 'Others'

  page_action :delete, method: :post do
    if !EmailValidator.valid?(params[:email])
      redirect_to admin_gdpr_delete_email_path, alert: 'Invalid email'
    elsif params[:email] != params[:email_confirm]
      redirect_to admin_gdpr_delete_email_path, alert: 'Emails dont match'
    else
      Users::GDPR::Delete.call(email: params[:email])

      redirect_to admin_root_path, notice: "Email scheduled for GDPR delete #{ params[:email] }"
    end
  end

  content do
    form(method: :post, action: admin_gdpr_delete_email_delete_path) do
      input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s

      div do
        label do
          div 'Email'
          input name: 'email', type: :email
        end
      end

      div do
        label do
          div 'Email confirm'
          input name: 'email_confirm', type: :email
        end
      end

      input type: 'submit', value: 'GDPR Delete'
    end
  end
end
