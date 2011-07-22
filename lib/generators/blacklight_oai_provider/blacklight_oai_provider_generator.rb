require 'rails/generators'

class BlacklightOaiProviderGenerator < Rails::Generators::Base

  argument :model_name, :type => :string, :default => "SolrDocument"
  argument :controller_name, :type => :string, :default => "CatalogController"

  def inject_solr_document_extension
    file_path = "app/models/#{model_name.underscore}.rb"

    if File.exists? file_path
      inject_into_file file_path, :after => "include Blacklight::Solr::Document" do
        "\n  SolrDocument.use_extension( BlacklightOaiProvider::SolrDocumentExtension )\n"
      end
    end
  end

  def inject_catalog_controller_extension
    file_path = "app/controllers/#{controller_name.underscore}.rb"
    if File.exists? file_path
      inject_into_file file_path, :after => "include Blacklight::Catalog" do
        "\n  include BlacklightOaiProvider::ControllerExtension\n"
      end
    end

  end
end
