require 'spec_helper'

describe Oas::Client do
  describe "campaign" do
    before(:each) do
      stub_api_call fixture("read_campaign.xml")
    end

    it "should return a campaign hash for a given id" do
      response = Oas.campaign("campaign_id")
      response.should_not be_nil
      response[:Campaign].should be_a(Hash)
      response[:Campaign][:Overview][:Id].should eq("campaign_id")
    end
  end

  describe "creative" do
    before(:each) do
      stub_api_call fixture("read_creative.xml")
    end

    it "should return a campaign hash for a given id" do
      response = Oas.creative("campaign_id", "creative_id")
      response.should_not be_nil
      response[:Creative].should be_a(Hash)
      response[:Creative][:CampaignId].should eq("campaign_id")
      response[:Creative][:Id].should eq("creative_id")
    end
  end
end
