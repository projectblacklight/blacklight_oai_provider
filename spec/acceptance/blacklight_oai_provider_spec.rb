# encoding: utf-8
require 'spec_helper'

describe 'Blacklight oai provider' do
  use_vcr_cassette "solr"
  before do
    CatalogController.configure_blacklight do |config|
      config.index.show_link = 'title_display'
      config.default_solr_params = {
        :rows => 10,
        :fl => 'id, title_display, author_display, format, timestamp'
      }
      
      config.oai = {
        :provider => {
          :repository_name => 'Test',
          :repository_url => 'http://localhost',
          :record_prefix => '',
          :admin_email => 'root@localhost'
        },
        :document => {
          :timestamp => 'timestamp',
          :limit => 25
        }
      }

    end
  end

  it "root page" do
    visit '/catalog/oai'
    page.should have_content 'not a legal OAI-PMH verb'
  end

  it "identify page" do
    visit '/catalog/oai?verb=Identify'
    page.should have_content 'root@localhost'
    page.should have_xpath('//earliestdatestamp', :content => '2012-08-01T16:49:55Z')
  end

  it "should list records" do
    visit '/catalog/oai?verb=ListRecords'
  end

  it "document page" do
    visit '/catalog/oai?verb=GetRecord&identifier=00282214'
    page.should have_xpath('//title', :content => 'Fikr-i Ayāz')
  end
end
