# encoding: utf-8
require 'spec_helper'

describe 'Blacklight oai provider' do
  it "root page" do
    visit '/catalog/oai'
    page.should have_content 'not a legal OAI-PMH verb'
  end

  it "identify page" do
    pending 'have to be updated to use capybary js tests'
    visit '/catalog/oai?verb=Identify'
    page.should have_content 'root@localhost'
    page.should have_xpath('//earliestdatestamp', :text => '2012-08-01T16:49:55Z')
  end

  it "should list records" do
    visit '/catalog/oai?verb=ListRecords'
  end

  it "document page" do
    pending 'have to be updated to use capybary js tests'
    visit '/catalog/oai?verb=GetRecord&identifier=00282214&metadataPrefix=oai_dc'
    page.should have_xpath('//title', :text => 'Fikr-i Ayāz')
  end
end
