require 'rails/generators'

module BlacklightOaiProvider
  class InstallGenerator < Rails::Generators::Base
    argument :model_name, type: :string, default: "SolrDocument"
    argument :controller_name, type: :string, default: "CatalogController"

    def inject_solr_document_concern
      file_path = "app/models/#{model_name.underscore}.rb"

      if File.exist? file_path
        inject_into_file file_path, after: "include Blacklight::Solr::Document" do
          "\n  include BlacklightOaiProvider::SolrDocument\n"
        end
      end
    end

    def inject_catalog_controller_concern
      file_path = "app/controllers/#{controller_name.underscore}.rb"
      if File.exist? file_path
        inject_into_file file_path, after: "include Blacklight::Catalog" do
          "\n  include BlacklightOaiProvider::Controller\n"
        end
      end
    end
  end
end
