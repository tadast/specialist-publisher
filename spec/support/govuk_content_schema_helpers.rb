require "govuk-content-schema-test-helpers/rspec_matchers"

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = "publisher"
  config.project_root = Rails.root
end

RSpec.configuration.include GovukContentSchemaTestHelpers::RSpecMatchers
