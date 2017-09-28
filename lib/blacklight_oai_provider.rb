module BlacklightOaiProvider
  autoload :ControllerExtension, 'blacklight_oai_provider/controller_extension'
  autoload :SolrDocumentExtension, 'blacklight_oai_provider/solr_document_extension'
  autoload :SolrDocumentProvider, 'blacklight_oai_provider/solr_document_provider'
  autoload :SolrDocumentWrapper, 'blacklight_oai_provider/solr_document_wrapper'
  autoload :RouteSets, 'blacklight_oai_provider/route_sets'

  require 'oai'
  require 'blacklight_oai_provider/version'
  require 'blacklight_oai_provider/engine'

  @omit_inject = {}
  def self.omit_inject=(value)
    value = Hash.new(true) if value == true
    @omit_inject = value
  end
  def self.omit_inject ; @omit_inject ; end

  def self.inject!
    unless BlacklightOaiProvider.omit_inject[:routes]
      Blacklight::Routes.send(:include, BlacklightOaiProvider::RouteSets)
    end
  end

  # Add element to array only if it's not already there
  def self.safe_arr_add(array, element)
    array << element unless array.include?(element)
  end

  # returns the full path the the blacklight plugin installation
  def self.root
    @root ||= File.expand_path(File.dirname(File.dirname(__FILE__)))
  end
end
