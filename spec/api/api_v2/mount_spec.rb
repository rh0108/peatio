require 'spec_helper'

module APIv2
  class Mount

    get "/broken" do
      raise Error, code: 2014310, text: 'MtGox bankrupt'
    end

  end
end

describe APIv2::Mount do

  context "handle exception on request processing" do
    it "should render json error message" do
      get "/api/v2/broken"
      response.code.should == '400'
      JSON.parse(response.body).should == {'error' => {'code' => 2014310, 'message' => "MtGox bankrupt"}}
    end
  end

  context "handle exception on request routing" do
    it "should render json error message" do
      get "/api/v2/non/exist"
      response.code.should == '404'
      response.body.should == "Not Found"
    end
  end

end
