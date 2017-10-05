require 'spec_helper'

describe 'OIA-PMH ListIdentifiers Request' do
  let(:xml) { Nokogiri::XML(response.body) }

  context 'for all documents' do
    before :example do
      get '/catalog/oai?verb=ListIdentifiers&metadataPrefix=oai_dc'
    end

    it 'returns 25 records' do
      expect(xml.xpath('//xmlns:ListIdentifiers/xmlns:header').count).to eql 25
    end

    it 'first record has identifier and timestamp' do
      expect(xml.at_xpath('//xmlns:ListIdentifiers/xmlns:header/xmlns:identifier').text).not_to eql ''
      expect(xml.at_xpath('//xmlns:ListIdentifiers/xmlns:header/xmlns:datestamp').text).not_to eql ''
    end

    it 'contains resumptionToken' do
      expect(xml.at_xpath('//xmlns:resumptionToken').text).to eql 'oai_dc.f(2014-02-03T18:42:53Z).u(2014-03-03T18:42:53Z):25'
    end
  end

  context 'with resumption_token' do
    before :example do
      get '/catalog/oai?verb=ListIdentifiers&resumptionToken=oai_dc.f(2014-02-03T18:42:53Z).u(2014-02-03T18:42:53Z):25'
    end

    it 'returns 5 records' do
      expect(xml.xpath('//xmlns:ListIdentifiers/xmlns:header').count).to eql 5
    end

    it 'first record has identifier and timestamp' do
      expect(xml.at_xpath('//xmlns:ListIdentifiers/xmlns:header/xmlns:identifier').text).not_to eql ''
      expect(xml.at_xpath('//xmlns:ListIdentifiers/xmlns:header/xmlns:datestamp').text).not_to eql ''
    end

    it 'does not contain a resumptionToken' do
      pending 'ResumptionToken needs to be removed if there aren\'t more records.'
      expect(xml.at_xpath('//xmlns:resumptionToken').text).to eql ''
    end
  end

  context 'for all documents within a time range' do
    before :example do
      get '/catalog/oai?verb=ListIdentifiers&metadataPrefix=oai_dc&from=2014-03-03&until=2014-04-03'
    end

    it 'returns 1 record' do
      pending 'Filtering by date needs to be implemented.'
      expect(xml.xpath('//xmlns:ListIdentifiers/xmlns:header').count).to eql 1
    end

    it 'does not contain a resumptionToken' do
      pending 'Filtering by date needs to be implemented implemented'
      expect(xml.at_xpath('//xmlns:resumptionToken').text).to eql ''
    end
  end
end
