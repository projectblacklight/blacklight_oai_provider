require "rails_helper"

RSpec.describe 'OAI-PMH catalog endpoint' do
  let(:repo_name) { 'My Test Repository' }
  let(:format) { 'oai_dc' }
  let(:limit) { 10 }
  let(:provider_config) { { repository_name: repo_name } }
  let(:document_config) { { limit: limit } }
  let(:oai_config) { { provider: provider_config, document: document_config } }

  before do
    CatalogController.configure_blacklight do |config|
      config.oai = oai_config
    end
  end

  describe 'root page' do
    it 'displays an error message about missing verb' do
      get oai_provider_catalog_path
      expect(response.body).to include('not a legal OAI-PMH verb')
    end
  end

  describe 'Identify verb' do
    scenario 'displays repository information' do
      get oai_provider_catalog_path(verb: 'Identify')
      expect(response.body).to include(repo_name)
    end
  end

  describe 'ListRecords verb', :vcr do
    scenario 'displays a limited list of records' do
      get oai_provider_catalog_path(verb: 'ListRecords', metadataPrefix: format)
      records = xpath '//xmlns:record'

      expect(records.count).to eq limit
    end

    context 'when number of records exceeds document limit' do
      let(:document_config) { { limit: 25 } }

      scenario 'a resumption token is provided' do
        params = { verb: 'ListRecords', metadataPrefix: format }
        expected_token = 'oai_dc.f(2014-01-22T18:42:53Z).u(2014-10-10T18:42:53Z):25'

        get oai_provider_catalog_path(params)
        token = xpath '//xmlns:resumptionToken'

        expect(token.text).to eq expected_token
      end

      scenario 'a resumption token displays the next page of records' do
        params = { verb: 'ListRecords', resumptionToken: "oai_dc.f(1970-01-01T00:00:00Z).u(2016-12-16T15:40:34Z):25" }

        get oai_provider_catalog_path(params)
        records = xpath '//xmlns:record'

        expect(records.count).to be 5
      end

      scenario 'the last page of records provides an empty resumption token' do
        params = { verb: 'ListRecords', resumptionToken: "oai_dc.f(1970-01-01T00:00:00Z).u(2016-12-16T15:40:34Z):25" }

        get oai_provider_catalog_path(params)
        token = xpath '//xmlns:resumptionToken'

        expect(token.count).to be 1
        expect(token.text).to be_empty
      end
    end

    context 'with a set' do
      let(:document_config) { { set_fields: 'language_facet' } }

      scenario 'only records from the set are returned' do
        params = { verb: 'ListRecords', metadataPrefix: format, set: 'language_facet:Japanese' }

        get oai_provider_catalog_path(params)
        records = xpath '//xmlns:record'

        expect(records.count).to be 2
      end
    end

    context 'with a from date' do
      scenario 'only records with a timestamp after the date are shown' do
        params = { verb: 'ListRecords', metadataPrefix: format, from: '2014-05-01' }

        get oai_provider_catalog_path(params)
        records = xpath '//xmlns:record'

        expect(records.count).to be 2
        expect(response.body).to include('2014-05-13T18:42:53Z')
        expect(response.body).not_to include('2014-01-22T18:42:53Z')
      end

      context 'and an until date' do
        scenario 'shows records between the dates' do
          params = { verb: 'ListRecords', metadataPrefix: format, from: '2014-02-05', until: '2014-10-02' }

          get oai_provider_catalog_path(params)
          records = xpath '//xmlns:record'

          expect(records.count).to be 6
          expect(response.body).to include('2014-05-13T18:42:53Z')
          expect(response.body).not_to include('2014-01-22T18:42:53Z')
          expect(response.body).not_to include('2014-10-10T18:42:53Z')
        end
      end
    end

    context 'with an until date' do
      scenario 'only records with a timestamp before the date are shown' do
        params = { verb: 'ListRecords', metadataPrefix: format, until: '2014-02-01' }

        get oai_provider_catalog_path(params)
        records = xpath '//xmlns:record'

        expect(records.count).to be 1
        expect(response.body).to include('2014-01-22T18:42:53Z')
        expect(response.body).not_to include('2014-02-03T18:42:53Z')
      end
    end
  end

  describe 'GetRecord verb', :vcr do
    scenario 'displays a single record' do
      identifier = "oai:localhost:00282214"

      get oai_provider_catalog_path(verb: 'GetRecord', metadataPrefix: format, identifier: identifier)
      records = xpath '//xmlns:record'

      expect(records.count).to be 1
      expect(response.body).to include(identifier)
    end
  end

  describe 'ListSets verb' do
    context 'without set configuration' do
      scenario 'shows that no sets exist' do
        get oai_provider_catalog_path(verb: 'ListSets')
        expect(response.body).to include('This repository does not support sets')
      end
    end

    context 'with set configuration', :vcr do
      let(:document_config) { { set_fields: 'language_facet' } }

      scenario 'shows all sets' do
        get oai_provider_catalog_path(verb: 'ListSets')
        sets = xpath '//xmlns:set'
        expect(sets.count).to be 11
      end

      scenario 'shows the correct verb' do
        get oai_provider_catalog_path(verb: 'ListSets')
        expect(response.body).to include('verb="ListSets"')
      end

      context 'where sets include descriptions' do
        let(:document_config) { { set_fields: 'language_facet', set_class: 'OaiSet' } }

        scenario 'shows the set description object' do
          get oai_provider_catalog_path(verb: 'ListSets')
          descriptions = xpath '//xmlns:set/xmlns:setDescription/oai_dc:dc/dc:description',
                               'xmlns' => 'http://www.openarchives.org/OAI/2.0/',
                               'dc' => 'http://purl.org/dc/elements/1.1/',
                               'oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/'

          expect(descriptions.count).to be 1
          expect(response.body).to include('This set begins with an H')
        end
      end
    end
  end

  describe 'ListMetadataFormats verb' do
    scenario 'lists the oai_dc format' do
      get oai_provider_catalog_path(verb: 'ListMetadataFormats')
      expect(response.body).to include(format)
    end
  end

  describe 'ListIdentifiers verb', :vcr do
    let(:expected_ids) { %w(oai:localhost:2005553155 oai:localhost:00313831) }

    scenario 'lists identifiers for works' do
      get oai_provider_catalog_path(verb: 'ListIdentifiers', metadataPrefix: format)
      expect(response.body).to include(*expected_ids)
    end
  end

  def xpath(str, opts = nil)
    Nokogiri::XML(response.body).xpath(str, opts)
  end
end
