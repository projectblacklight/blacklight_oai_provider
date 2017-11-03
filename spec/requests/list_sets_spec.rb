require "spec_helper"

RSpec.describe 'OAI-PMH ListSets Request' do
  let(:xml) { Nokogiri::XML(response.body) }
  let(:namespaces) do
    {
      dc: 'http://purl.org/dc/elements/1.1/',
      xmlns: 'http://www.openarchives.org/OAI/2.0/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    }
  end

  context 'without set configuration' do
    it 'shows that no sets exist' do
      get oai_provider_path(verb: 'ListSets')
      expect(xml.xpath('//xmlns:error').text).to eql 'This repository does not support sets.'
    end
  end

  context 'with set configuration' do
    let(:document_config) { { set_fields: 'language_facet' } }

    it 'shows all sets' do
      pending 'Solr query for sets needs to be corrected.'
      get oai_provider_path(verb: 'ListSets')
      expect(xml.xpath('//xmlns:set').count).to be 11
    end

    it 'shows the correct verb' do
      pending 'Need to complete implementation of ListSets'
      get oai_provider_path(verb: 'ListSets')
      expect(xml.at_xpath('//xmlns:request').attribute('verb').value).to eql 'ListSets'
    end
  end
end
