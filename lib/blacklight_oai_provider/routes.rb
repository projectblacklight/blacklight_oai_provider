module BlacklightOaiProvider
  module Routes
    extend ActiveSupport::Concern

    included do |klass|
      klass.default_route_sets.insert(klass.default_route_sets.index(:export), :oai_routing)
    end

    def oai_routing(primary_resource)
      add_routes do
        get "#{primary_resource}/oai", to: "#{primary_resource}#oai", as: 'oai_provider'
      end
    end
  end
end
