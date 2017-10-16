require 'spec_helper'

describe CatalogController do
  it "should have a Blacklight module" do
    expect(Blacklight).to be_a_kind_of Module
  end

  it 'should have blacklight configuration' do
    expect(CatalogController.blacklight_config).to be_a_kind_of Blacklight::Configuration
  end

  describe '#oai' do
    it 'should respond to oai' do
      expect(controller).to respond_to :oai
    end
  end

  describe '#oai_config' do
    it 'returns correct configuration' do
      expect(controller.oai_config).to match(
        :provider => {
          :repository_name => "Test Repository",
          :repository_url => "http://localhost",
          :record_prefix => "test",
          :admin_email => "root@localhost",
          :deletion_support => "persistent",
          :sample_id => "109660"
        },
        :document => { :timestamp => "timestamp", :limit => 25 }
      )
    end
  end

  describe '#oai_provider' do
    it 'returns BlacklightOaiProvider::SolrDocumentProvider' do
      expect(controller.oai_provider).to be_a BlacklightOaiProvider::SolrDocumentProvider
    end
  end
end
