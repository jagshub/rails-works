# frozen_string_literal: true

class API::Shared::DocsController < ApplicationController
  layout 'api_v1_docs'

  before_action :load_paths
  before_action :load_resources

  def index
    page_title('Product Hunt API Documentation')
  end

  def show
    filename = params[:id] + '.json'

    unless valid_file?(filename)
      redirect_to @base_url
      return
    end

    filename = Rails.root.join(@directory, filename)
    @example = JSON.parse(File.read(filename))
    @example['requests'].each do |r|
      r['request_body']  = format_body r['request_body'],  r['request_content_type']
      r['response_body'] = format_body r['response_body'], r['response_content_type']
    end

    @extra_parameter_names = @example['parameters'].map(&:keys).flatten - %w(name description required scope)

    page_title("Product Hunt API: #{ @example['resource'] }")
    meta_tags(description: @example['description'])
  end

  private

  def load_resources
    index_file   = Rails.root.join(@directory, 'index.json')
    @resources   = JSON.parse(File.read(index_file))['resources']
  end

  def format_body(body, type)
    return unless type =~ /json/ && body.present? && body != ' '

    JSON.pretty_generate(JSON.parse(body))
  end

  def valid_file?(filename)
    valid_files = @resources.map { |r| r['examples'].map { |e| e['link'] } }.flatten
    valid_files.include?(filename)
  end
end
