module BlacklightOaiProvider::SolrDocument
  extend ActiveSupport::Concerns

  def timestamp
    timestamp = get('timestamp')
    raise BlacklightOaiProvider::Exceptions::MissingTimestamp if timestamp.blank?
    Time.parse timestamp
  end

  def to_oai_dc
    export_as('oai_dc_xml')
  end
end
