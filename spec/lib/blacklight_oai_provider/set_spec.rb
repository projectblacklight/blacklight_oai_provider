require 'rails_helper'

RSpec.describe BlacklightOaiProvider::Set do
  let(:controller) { CatalogController.new }
  let(:fields) { 'language_facet' }

  before do
    described_class.repository = controller.repository
    described_class.search_builder = controller.search_builder
    described_class.fields = fields
  end

  describe '.all', :vcr do
    it 'returns a Set object representing each set' do
      sets = described_class.all
      expect(sets.count).to be 11
      expect(sets.first).to be_a described_class
    end

    context 'with multiple fields' do
      let(:fields) { %w(language_facet format) }

      it 'returns Sets for values in each field' do
        expect(described_class.all.count).to be 12
      end
    end

    context 'for a field with no values' do
      let(:fields) { 'author_display' }

      it 'returns nil' do
        expect(described_class.all).to be_nil
      end
    end
  end

  describe '.from_spec' do
    context 'with a valid spec' do
      let(:spec) { 'language_facet:Hebrew' }

      it 'returns the filter query' do
        expect(described_class.from_spec(spec)).to eq 'language_facet:Hebrew'
      end
    end

    context 'with an invalid field' do
      let(:spec) { 'foo:Hebrew' }

      it 'raises an argument exception' do
        expect { described_class.from_spec(spec) }.to raise_error(::OAI::ArgumentException)
      end
    end

    context 'with an invalid spec' do
      let(:spec) { 'invalid' }

      it 'raises an argument exception' do
        expect { described_class.from_spec(spec) }.to raise_error(::OAI::ArgumentException)
      end
    end
  end

  describe '#initialize' do
    it 'creates a friendly set name if none is provided' do
      set = described_class.new('language_facet:Hebrew')
      expect(set.name).to eq 'Language Facet: Hebrew'
    end
  end
end
