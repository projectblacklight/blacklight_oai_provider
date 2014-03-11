module BlacklightOaiProvider

  module RouteSets
    protected
    def catalog
      add_routes do |options|
        get 'catalog/oai' => 'catalog#oai', :as => 'oai_provider'
      end

      super
    end
  end
end

