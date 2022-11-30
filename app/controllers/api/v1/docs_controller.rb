# frozen_string_literal: true

class API::V1::DocsController < API::Shared::DocsController
  private

  def load_paths
    @base_url  = Routes.api_v1_docs_path
    @directory = 'doc/api/v1'
  end
end
