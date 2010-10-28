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
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_dc:dc",
             'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
             'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
       self.to_semantic_values.each do |field,values|
         values.each do |v|
           xml.tag! 'dc:' + field.to_s, v
         end
       end
     end

     xml.target!
  end
end
