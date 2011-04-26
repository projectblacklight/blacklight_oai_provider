# BlacklightOaiProvider

module BlacklightOaiProvider
  
  @omit_inject = {}
  def self.omit_inject=(value)
    value = Hash.new(true) if value == true
    @omit_inject = value      
  end
  def self.omit_inject ; @omit_inject ; end
  
  def self.inject!
      unless omit_inject[:solrdocument_mixin]
        SolrDocument.send(:include, BlacklightOaiProvider::SolrDocumentOverride) unless SolrDocument.include?(BlacklightOaiProvider::SolrDocumentOverride)
      end

      unless omit_inject[:view_helpers]
        CatalogController.helper(
          BlacklightOaiProvider::ViewHelperOverride
        ) unless
         CatalogController._helpers.include?( 
            BlacklightOaiProvider::ViewHelperOverride
         )
        CatalogController.helper(
          OaiProviderHelper
         ) unless
          CatalogController._helpers.include?( 
            OaiProviderHelper
          )
      end

      unless omit_inject[:controller_mixin]
        CatalogController.send(:include, BlacklightOaiProvider::ControllerOverride) unless CatalogController.include?(BlacklightOaiProvider::ControllerOverride)
      end
  end

  # Add element to array only if it's not already there
  def self.safe_arr_add(array, element)
    array << element unless array.include?(element)
  end
  
end
