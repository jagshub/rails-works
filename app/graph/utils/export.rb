# frozen_string_literal: true

module Graph::Utils::Export
  extend self

  TARGET_DIR = Rails.root.join('frontend', 'types').freeze

  def delete_existing_files
    Dir[TARGET_DIR.join('graphql', '*')].each do |path|
      next if File.basename(path) == 'globalTypes.ts'

      FileUtils.rm(path)
    end
  end

  def export_schema(schema_type)
    schema = schema_type.execute(GraphQL::Introspection::INTROSPECTION_QUERY, variables: {}, context: {})
    if schema_type == Graph::Schema
      File.write(TARGET_DIR.join('graphqlSchema.json'), JSON.pretty_generate(schema))
    else
      File.write(Rails.root.join('graphqlSchema.json'), JSON.pretty_generate(schema))
    end
  end

  def export_fragment_types
    query = '{__schema {types { kind name possibleTypes { name } } } }'
    fragments_matcher = Graph::Schema.execute(query, variables: nil, context: nil)

    data = fragments_matcher['data']['__schema']['types'].compact
    types = data.select { |fragment| fragment['possibleTypes'].present? }

    File.write(
      TARGET_DIR.join('graphqlFragmentTypes.json'),
      JSON.pretty_generate("__schema": { "types": types }),
    )
  end

  def run_apollo_codegen
    system('bin/yarn', 'run', 'apollo:codegen',
           '--localSchemaFile', 'types/graphqlSchema.json',
           '--addTypename',
           '--target', 'typescript',
           '--includes', './**/*.graphql',
           '--outputFlat', 'types/graphql',
           %i(out err) => [Rails.root.join('tmp', 'apollo_codegen_output.txt'), 'w'],
           exception: true)
  rescue RuntimeError
    output = Rails.root.join('tmp', 'apollo_codegen_output.txt')
                  .read
                  .gsub(%r{\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])}, '')
    raise "Apollo codegen error:\n#{ output }"
  end
end
