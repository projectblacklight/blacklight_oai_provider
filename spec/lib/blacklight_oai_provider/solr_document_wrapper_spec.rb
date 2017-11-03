require 'spec_helper'

RSpec.describe BlacklightOaiProvider::SolrDocumentWrapper do
  let(:options) { {} }
  let(:controller) { CatalogController.new }
  subject { described_class.new(controller, options) }

  before do
    allow(controller).to receive(:params).and_return({})
  end

  describe '#initialize' do
    context 'with a set class provided' do
      let(:options) { { set_class: '::OaiSet', set_fields: 'language_facet' } }

      it 'uses the Set class' do
        pending 'Need to add alternate Set class implementation'
        expect(subject.sets.first).to be_a ::OaiSet
      end
    end
  end

  describe '#sets' do
    it 'returns nil to indicate sets are not supported' do
      expect(subject.sets).to be_nil
    end
  end

  describe '#earliest' do
    it 'returns the earliest timestamp of all the records' do
      expect(subject.earliest).to eq Time.parse('2014-02-03 18:42:53.056000000 +0000').utc
    end
  end

  describe '#latest' do
    it 'returns the latest timestamp of all the records' do
      expect(subject.latest).to eq Time.parse('2014-03-03 18:42:53.056000000 +0000').utc
    end
  end

  describe '#find' do
    context 'when selector is :all' do
      it 'returns a limited list of all records' do
        expect(subject.find(:all)).to be_a OAI::Provider::PartialResult
        expect(subject.find(:all).records.size).to be 15
      end
    end

    context 'when selector is an individual record' do
      it 'returns a single record' do
        expect(subject.find('2005553155')).to be_a SolrDocument
      end
    end
  end
end
