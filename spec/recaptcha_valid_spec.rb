require File.join(File.dirname(__FILE__), "spec_helper")

class FakeController < Merb::Controller
  def check_recaptcha
    return recaptcha_valid?.to_s
  end
end

describe "FakeController#check_recaptcha" do
  def do_request
    @response = dispatch_to(FakeController, "check_recaptcha", { :recaptcha_challenge_field => "blabla", :recaptcha_response_field => "blabla" })
  end

  def stub_response(body)
    Net::HTTP.stub!(:post_form).and_return mock("Net::HTTPResponse", :body => body)
  end

  describe "with correct response" do
    before(:each) do
      stub_response("true\n")
    end

    it "should render 'true'" do
      do_request
      @response.should have_selector("*:contains('true')")
    end
    
    it "should not raise any exception" do
      lambda { do_request }.should_not raise_error
    end
  end

  describe "with incorrect response" do
    before(:each) do
      stub_response("false\nincorrect-captcha-sol\n")
    end

    it "should render 'false'" do
      do_request
      @response.should have_selector("*:contains('false')")
    end
    
    it "should not raise any exception" do
      lambda { do_request }.should_not raise_error
    end
  end
  
  describe "with incorrect public key" do
    before(:each) do
      stub_response("false\ninvalid-site-public-key\n")
    end

    it "should raise Merb::Recaptcha::InvalidSitePublicKey" do
      lambda { do_request }.should raise_error(Merb::Recaptcha::InvalidSitePublicKey)
    end
  end
  
  describe "with incorrect private key" do
    before(:each) do
      stub_response("false\ninvalid-site-private-key\n")
    end

    it "should raise Merb::Recaptcha::InvalidSitePrivateKey" do
      lambda { do_request }.should raise_error(Merb::Recaptcha::InvalidSitePrivateKey)
    end
  end
  
  describe "with invalid request cookie" do
    before(:each) do
      stub_response("false\ninvalid-request-cookie\n")
    end

    it "should raise Merb::Recaptcha::InvalidRequestCookie" do
      lambda { do_request }.should raise_error(Merb::Recaptcha::InvalidRequestCookie)
    end
  end

  describe "with verify parameters incorrect" do
    before(:each) do
      stub_response("false\nverify-params-incorrect\n")
    end

    it "should raise Merb::Recaptcha::VerifyParamsIncorrect" do
      lambda { do_request }.should raise_error(Merb::Recaptcha::VerifyParamsIncorrect)
    end
  end

  describe "with invalid referrer" do
    before(:each) do
      stub_response("false\ninvalid-referrer\n")
    end

    it "should raise Merb::Recaptcha::IvalidReferrer" do
      lambda { do_request }.should raise_error(Merb::Recaptcha::InvalidReferrer)
    end
  end
end
