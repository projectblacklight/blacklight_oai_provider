# Meant to be applied on top of a controller that implements
# Blacklight::SolrHelper. Will inject range limiting behaviors
# to solr parameters creation. 
module BlacklightOaiProvider::ControllerExtension
  def self.included(some_class)
    some_class.helper_method :oai_config
  end

  # Action method of our own!
  # Delivers a _partial_ that's a display of a single fields range facets.
  # Used when we need a second Solr query to get range facets, after the
  # first found min/max from result set. 
  def oai
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    render :text => oai_provider.process_request(options).gsub('<?xml version="1.0" encoding="UTF-8"?>', "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<?xml-stylesheet type=\"text/xsl\" href=\"#{ ActionController::Base.helpers.asset_path('oai2.xsl')}\" ?>"), :content_type => 'text/xml'
  end

  # Uses Blacklight.config, needs to be modified when
  # that changes to be controller-based. This is the only method
  # in this plugin that accesses Blacklight.config, single point
  # of contact.
  def oai_config
    blacklight_config.oai || {}
  end

  def oai_provider
    @oai_provider ||= BlacklightOaiProvider::SolrDocumentProvider.new(self, oai_config)
  end
end
