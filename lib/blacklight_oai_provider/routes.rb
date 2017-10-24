module BlacklightOaiProvider
  module Routes
    extend ActiveSupport::Concern

    included do |klass|
      klass.default_route_sets.insert(klass.default_route_sets.index(:catalog), :oai_routing)
    end

    def oai_routing
      add_routes do
        get "catalog/oai", to: "catalog#oai", as: 'oai_provider'
      end
    end
  end
end
