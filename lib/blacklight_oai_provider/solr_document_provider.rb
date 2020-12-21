module BlacklightOaiProvider
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options

    def initialize(controller, options = {})
      options[:provider] ||= {}
      options[:document] ||= {}

      self.class.model = SolrDocumentWrapper.new(controller, options[:document])

      options[:provider][:repository_name] ||= controller.view_context.application_name
      options[:provider][:repository_url] ||= controller.view_context.oai_catalog_url

      options[:provider].each do |k, v|
        v = v.call(controller) if v.is_a?(Proc)
        self.class.send k, v
      end
    end

    def list_sets(options = {})
      Response::ListSets.new(self.class, options).to_xml
    end
  end
end
