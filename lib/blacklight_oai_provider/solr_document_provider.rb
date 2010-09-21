require 'oai'
module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    include Blacklight::SolrHelper
    attr_reader :model, :timestamp_field
    def initialize(options = {})
      @model = Blacklight.solr 
      @timestamp_field = options.delete(:timestamp_field) || 'timestamp'
      @limit = options.delete(:limit)
    end

    def sets
    end

    def earliest
      Time.parse get_search_results({:sort => @timestamp_field +' asc', :rows => 1}).last.first.get(@timestamp_field)
    end

    def latest
      Time.parse get_search_results({:sort => @timestamp_field +' desc', :rows => 1}).last.first.get(@timestamp_field)
    end

    def find(selector, options={})
                          return next_set(options[:resumption_token]) if options[:resumption_token]
                        if :all == selector
                                response, records = get_search_results({:sort => @timestamp_field + ' asc', :rows => @limit})
                                total = records.count

                                if @limit && total >= @limit
                                        return select_partial ResumptionToken.new options.merge({:last => 0})
                                end
                        else
                                records = get_search_results({:id => selector}).last
                        end
                        records

    end
    def select_partial token
                        records = get_search_results({:sort => @timestamp_field + ' asc', :rows => @limit, :start => token.last}).last

                        raise ::OAI::ResumptionTokenException.new unless records

                        PartialResult.new(records, token.next(@limit + token.last))
                    end

                    def next_set(token_string)
                        raise ::OAI::ResumptionTokenException.new unless @limit

                        token = ResumptionToken.parse token_string
                        select_partial token
                    end

    def extra_controller_params

    end
def params
  {}
end
def facet_limit_hash
  {}
end
  end
  class SolrDocumentProvider < ::OAI::Provider::Base
    Blacklight.config[:oai][:provider].each do |k, v|
      self.send k, v
    end
    source_model SolrDocumentWrapper.new Blacklight.config[:oai][:document]
  end
end
