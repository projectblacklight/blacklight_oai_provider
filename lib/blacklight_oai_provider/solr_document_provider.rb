require 'oai'
module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    include Blacklight::SolrHelper
    attr_reader :model, :timestamp_field
    attr_accessor :params, :extra_controller_params
    attr_reader :facet_limit_hash
    def initialize(options = {})
      defaults = { :timestamp_field => 'timestamp', :limit => 15} 
      @options = defaults.merge options
      @model = Blacklight.solr 
      @timestamp_field = @options.delete(:timestamp_field) 
      @limit = @options.delete(:limit)
      @params = {}
      @facet_limit_hash = {}
      @extra_controller_params = @options
    end

    def sets
    end

    def earliest
      Time.parse get_search_results({:sort => @timestamp_field +' asc', :rows => 1}.merge(extra_controller_params)).last.first.get(@timestamp_field)
    end

    def latest
      Time.parse get_search_results({:sort => @timestamp_field +' desc', :rows => 1}.merge(extra_controller_params)).last.first.get(@timestamp_field)
    end

    def find(selector, options={})
                          return next_set(options[:resumption_token]) if options[:resumption_token]
                        if :all == selector
                                response, records = get_search_results({:sort => @timestamp_field + ' asc', :rows => @limit}.merge(extra_controller_params))
                                total = records.count

                                if @limit && total >= @limit
                                        return select_partial ResumptionToken.new options.merge({:last => 0})
                                end
                        else
                                records = get_search_results(:phrase_filters => {:id => selector.split('/', 2).last}.merge(extra_controller_params)).last.first
                        end
                        records

    end
    def select_partial token
                        records = get_search_results({:sort => @timestamp_field + ' asc', :rows => @limit, :start => token.last}.merge(extra_controller_params)).last

                        raise ::OAI::ResumptionTokenException.new unless records

                        PartialResult.new(records, token.next(@limit + token.last))
                    end

                    def next_set(token_string)
                        raise ::OAI::ResumptionTokenException.new unless @limit

                        token = ResumptionToken.parse token_string
                        select_partial token
                    end
  end
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options
    def initialize options = {}
      @options = Blacklight.config[:oai][:document].merge(options)
      SolrDocumentProvider.model = SolrDocumentWrapper.new(@options)
      SolrDocumentProvider.url = (options.delete(:repository_url) if options[:repository_url]) || Blacklight.config[:oai][:provider][:repository_url]
    end

    Blacklight.config[:oai][:provider].each do |k, v|
      self.send k, v
    end
    #source_model SolrDocumentWrapper.new(@options) # Blacklight.config[:oai][:document]
  end
end
