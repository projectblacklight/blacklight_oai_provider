# BlacklightOaiProvider

module BlacklightOaiProvider
  
  @omit_inject = {}
  def self.omit_inject=(value)
    value = Hash.new(true) if value == true
    @omit_inject = value      
  end
  def self.omit_inject ; @omit_inject ; end
  
  def self.inject!
    Dispatcher.to_prepare do
      
      unless omit_inject[:solrdocument_mixin]
        SolrDocument.send(:include, BlacklightOaiProvider::SolrDocumentOverride) unless SolrDocument.include?(BlacklightOaiProvider::SolrDocumentOverride)
      end

      unless omit_inject[:view_helpers]
        CatalogController.add_template_helper(
          BlacklightOaiProvider::ViewHelperOverride
        ) unless
         CatalogController.master_helper_module.include?( 
            BlacklightOaiProvider::ViewHelperOverride
         )
        CatalogController.add_template_helper(
          OaiProviderHelper
         ) unless
          CatalogController.master_helper_module.include?( 
            OaiProviderHelper
          )
      end

      unless omit_inject[:controller_mixin]
        CatalogController.send(:include, BlacklightOaiProvider::ControllerOverride) unless CatalogController.include?(BlacklightOaiProvider::ControllerOverride)
      end
      
    end
  end

  # Add element to array only if it's not already there
  def self.safe_arr_add(array, element)
    array << element unless array.include?(element)
  end
  
end
