require 'spec_helper'

RSpec.describe BlacklightOaiProvider::SolrDocumentWrapper do
  subject(:wrapper) { described_class.new(controller, options) }

  let(:options) { {} }
  let(:controller) { CatalogController.new }

  before do
    allow(controller).to receive(:params).and_return({})
  end

  describe '#initialize' do
    context 'with a set class provided' do
      before do
        stub_const 'CustomSet', Class.new(BlacklightOaiProvider::Set)
      end

      let(:options) { { set_model: CustomSet, set_fields: [{ solr_field: 'language_facet' }] } }

      it 'uses the Set class' do
        expect(wrapper.instance_eval { @set }).to be CustomSet
      end
    end
  end

  describe '#sets' do
    it 'returns nil to indicate sets are not supported' do
      expect(wrapper.sets).to be_nil
    end
  end

  describe '#earliest' do
    it 'returns the earliest timestamp of all the records' do
      expect(wrapper.earliest).to eq Time.parse('2014-02-03 18:42:53.056000000 +0000').utc
    end
  end

  describe '#latest' do
    it 'returns the latest timestamp of all the records' do
      expect(wrapper.latest).to eq Time.parse('2015-02-03 18:42:53.056000000 +0000').utc
    end
  end

  describe '#find' do
    context 'when selector is :all' do
      it 'returns a limited list of all records' do
        expect(wrapper.find(:all)).to be_a OAI::Provider::PartialResult
        expect(wrapper.find(:all).records.size).to be 15
      end
    end

    context 'when selector is an individual record' do
      class VisibilityAwareSearchBuilder < Blacklight::SearchBuilder
        include Blacklight::Solr::SearchBuilderBehavior
        self.default_processor_chain += [:only_visible]

        def only_visible(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << 'visibility_si:"open"'
        end
      end

      before do
        allow(controller).to receive(:search_builder_class).and_return(VisibilityAwareSearchBuilder)
      end

      context 'with a restricted work' do
        it 'returns nothing' do
          expect(wrapper.find('2007020969')).to be_nil
        end
      end

      context 'with a public work' do
        it 'returns a single record' do
          expect(wrapper.find('2005553155')).to be_a SolrDocument
        end
      end
    end
  end
end
