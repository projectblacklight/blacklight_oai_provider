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
      pending 'Figure out a way to override blacklight configuration'
      get oai_provider_path(verb: 'ListSets')
      expect(xml.xpath('//xmlns:error').text).to eql 'This repository does not support sets.'
    end
  end

  context 'with set configuration' do
    it 'shows all sets' do
      get oai_provider_path(verb: 'ListSets')
      expect(xml.xpath('//xmlns:set').count).to be 12
    end

    it 'shows the correct verb' do
      get oai_provider_path(verb: 'ListSets')
      expect(xml.at_xpath('//xmlns:request').attribute('verb').value).to eql 'ListSets'
    end
  end

  context 'when set configuration contains description' do
    before do
      CatalogController.configure_blacklight do |config|
        config.oai = {
          document: {
            set_fields: [
              { label: 'subject', solr_field: 'subject_topic_facet',
                description: "Subject topic set using FAST subjects" }
            ]
          }
        }
      end
    end

    it 'shows set description' do
      get oai_provider_path(verb: 'ListSets')
      expect(
        xml.at_xpath('//xmlns:set/xmlns:setDescription/oai_dc:dc/dc:description', namespaces).text
      ).to eql 'Subject topic set using FAST subjects'
    end
  end
end
