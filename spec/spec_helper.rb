ENV["RAILS_ENV"] ||= 'test'
require 'rsolr'
require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
require 'capybara/rspec'

#
# # Setup blacklight environment
# Blacklight.solr_config = { :url => 'http://127.0.0.1:8983/solr' }
# CatalogController.send(:include, BlacklightOaiProvider::ControllerExtension)
#
# class SolrDocument
#   include Blacklight::Solr::Document
#   include BlacklightOaiProvider::SolrDocumentExtension
#   use_extension( Blacklight::Solr::Document::DublinCore)
#   field_semantics.merge!(
#                          :title => "title_display",
#                          :author => "author_display",
#                          :language => "language_facet",
#                          :format => "format"
#                          )
#
# end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
