module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    DEFAULT_CONFIG = { :timestamp => 'timestamp', :limit => 15 }.freeze

    attr_accessor :options

    def initialize(controller, options = {})
      @controller = controller
      @options = DEFAULT_CONFIG.merge(options)
      @timestamp_field = options[:timestamp]
      @limit = options[:limit]
    end

    def sets
    end

    def earliest
      Time.parse @controller.get_search_results(@controller.params, {:fl => @timestamp_field, :sort => @timestamp_field +' asc', :rows => 1}).last.first.get(@timestamp_field)
    end

    def latest
      Time.parse @controller.get_search_results(@controller.params, {:fl => @timestamp_field, :sort => @timestamp_field +' desc', :rows => 1}).last.first.get(@timestamp_field)
    end

    def find(selector, options={})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if :all == selector
        response, records = @controller.get_search_results(@controller.params, conditions(options))

        if @limit && response.total > @limit
          return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge({:last => 0}), nil, response.total))
        end
      else
        response, records = @controller.get_solr_response_for_doc_id selector.split('/', 2).last
      end
      records
    end

    def select_partial token
      response, records = @controller.get_search_results(@controller.params, token_conditions(token))

      raise ::OAI::ResumptionTokenException.new unless records

      OAI::Provider::PartialResult.new(records, token.next(token.last + @limit))
    end

    def next_set(token_string)
      raise ::OAI::ResumptionTokenException.new unless @limit

      token = BlacklightOaiProvider::ResumptionToken.parse(token_string)
      select_partial(token)
    end

    private

    def base_conditions
      { :sort => "#{@timestamp_field} asc", :rows => @limit }
    end

    def token_conditions(token)
      base_conditions.merge({:start => token.last})
    end

    def conditions(options) # conditions/query derived from options
      if !(options[:from].blank? && options[:until].blank?)
        base_conditions.merge(
          { :fq => "#{timestamp_field}:[#{solr_date(options[:from])} TO #{solr_date(options[:until]).gsub('Z', '.999Z')}]" }
        )
      else
        base_conditions
      end
    end

    def solr_date(time)
      if time.respond_to?(:xmlschema)
        time.xmlschema
      elsif time.blank?
        '*'
      else
        time.to_s
      end
    end
  end
end
