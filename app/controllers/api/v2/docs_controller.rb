# frozen_string_literal: true

class API::V2::DocsController < API::Shared::DocsController
  layout 'api_v2_docs'

  private

  def load_paths
    @base_url  = Routes.api_v2_docs_path
    @directory = 'doc/api/v2'
  end
end
