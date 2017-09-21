require 'bundler'

Bundler.require :default, :development

Combustion.initialize! :all do
  config.assets.precompile += %w( oai2.xsl ) ## Needs to be added as a generator
end

# Setup blacklight environment
Blacklight.solr_config = { :url => 'http://127.0.0.1:8983/solr' }
CatalogController.send(:include, BlacklightOaiProvider::ControllerExtension)

class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocumentExtension
  use_extension( Blacklight::Solr::Document::DublinCore)
  field_semantics.merge!(
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )

end

require 'vcr'

VCR.configure do |config|
  config.hook_into :fakeweb
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.default_cassette_options = { :serialize_with => :syck }
end

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end
