# Meant to be applied on top of SolrDocument to implement
# methods required by the ruby-oai provider
module BlacklightOaiProvider::SolrDocumentOverride
  def self.extended(document)
    document.will_export_as(:oai_dc_xml, 'text/xml')
  end
  def timestamp
    Time.parse get('timestamp')
  end
  def to_oai_dc
    export_as('oai_dc_xml')
  end
  def export_as_oai_dc_xml
    '' # tk
  end
end
