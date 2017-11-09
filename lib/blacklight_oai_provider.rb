module BlacklightOaiProvider
  autoload :Exceptions, 'blacklight_oai_provider/exceptions'
  autoload :SolrDocumentProvider, 'blacklight_oai_provider/solr_document_provider'
  autoload :SolrDocumentWrapper, 'blacklight_oai_provider/solr_document_wrapper'
  autoload :ResumptionToken, 'blacklight_oai_provider/resumption_token'
  autoload :Routes, 'blacklight_oai_provider/routes'
  autoload :Set, 'blacklight_oai_provider/set'
  autoload :Response, 'blacklight_oai_provider/response/list_sets'

  require 'oai'
  require 'blacklight_oai_provider/version'
  require 'blacklight_oai_provider/engine'

  @omit_inject = {}
  def self.omit_inject=(value)
    value = Hash.new(true) if value == true
    @omit_inject = value
  end

  def self.omit_inject
    @omit_inject
  end

  def self.inject!
    Blacklight::Routes.send(:include, BlacklightOaiProvider::Routes) unless BlacklightOaiProvider.omit_inject[:routes]
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
