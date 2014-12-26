require 'spec_helper'
#require File.expand_path('../../../spec_helper', __FILE__)

describe OmniAuth::Strategies::QQ do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}, :scheme=>"http", :url=>"localhost") }
  let(:app) { ->{[200, {}, ["Hello."]]}}
  let(:client){OAuth2::Client.new('appid', 'secret')}

  subject do
    OmniAuth::Strategies::QQ.new(app, 'appid', 'secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe '#client_options' do
    specify 'has site' do
      expect(subject.client.site).to eq('https://graph.qq.com')
    end

    specify 'has authorize_url' do
      expect(subject.client.options[:authorize_url]).to eq('/oauth2.0/authorize')
    end

    specify 'has token_url' do
      expect(subject.client.options[:token_url]).to eq('/oauth2.0/token')
    end
  end

  describe '#token_params' do
    specify "token response should be parsed as json" do
      expect(subject.token_params[:parse]).to eq(:query)
    end
  end

  describe 'state' do
    specify 'should set state params for request as a way to verify CSRF' do
      expect(subject.authorize_params['state']).not_to be_nil
      expect(subject.authorize_params['state']).to eq(subject.session['omniauth.state'])
    end
  end


  describe "#request_phase" do
    specify "redirect uri includes 'appid', 'redirect_uri', 'response_type', 'scope', 'state' and 'wechat_redirect' fragment " do
      callback_url = "http://exammple.com/callback"
      expect(subject).to receive(:callback_url).and_return(callback_url)
      expect(subject).to receive(:redirect).with(valid_redirect_url(callback_url))
      subject.request_phase
    end
  end

  def valid_redirect_url(callback_url)
    satisfy do |actual_redirect_url|
        uri = URI.parse(actual_redirect_url)
        params = CGI::parse(uri.query)
        expect(params["client_id"]).to eq(['appid'])
        expect(params["redirect_uri"]).to eq([callback_url])
        expect(params["response_type"]).to eq(['code'])
        expect(params["state"]).to eq([subject.session['omniauth.state']])
    end
  end

  describe "#uid" do
    let(:access_token) { OAuth2::AccessToken.from_hash(client, {})}
    before { 
      expect(access_token).to receive(:get).with('/oauth2.0/me').and_return(
        double("response", body: 'callback( {"client_id":"YOUR_APPID","openid":"YOUR_OPENID"} );'))
      allow(subject).to receive(:access_token).and_return(access_token)
    }

    specify {expect(subject.uid).to eq("YOUR_OPENID")}
  end

  describe "#raw_info" do
    let(:access_token) { OAuth2::AccessToken.from_hash(client, {}) }

    let(:user_info_response) {double("response", body: user_info_response_body) }
    before {
      expect(access_token).to receive(:get).with('/oauth2.0/me')
      .and_return(
        double("response", body: 'callback( {"client_id":"YOUR_APPID","openid":"YOUR_OPENID"} );'))
      expect(access_token).to receive(:get).with("/user/get_user_info", 
                                                 {:params=> {:openid=>"YOUR_OPENID", :oauth_consumer_key=>"appid", :format=>:json},
                                                  :parse=>:json})
      .and_return(user_info_response)
      expect(user_info_response).to receive(:parsed).and_return(JSON.parse(user_info_response.body))
      allow(subject).to receive(:access_token).and_return(access_token)
    }
    specify {expect(subject.raw_info).to eq(user_info_response_parsed_hash)}

  end

  def user_info_response_body
    <<-EOF
     {
      "ret": 0,
      "msg": "",
      "is_lost":0,
      "nickname": "Stanley",
      "gender": "男",
      "province": "北京",
      "city": "",
      "year": "1977",
      "figureurl": "http:\/\/qzapp.qlogo.cn\/qzapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/30",
      "figureurl_1": "http:\/\/qzapp.qlogo.cn\/qzapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/50",
      "figureurl_2": "http:\/\/qzapp.qlogo.cn\/qzapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/100",
      "figureurl_qq_1": "http:\/\/q.qlogo.cn\/qqapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/40",
      "figureurl_qq_2": "http:\/\/q.qlogo.cn\/qqapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/100",
      "is_yellow_vip": "0",
      "vip": "0",
      "yellow_vip_level": "0",
      "level": "0",
      "is_yellow_year_vip": "0"
    } 
    EOF
  end

  def user_info_response_parsed_hash
    {
      "ret"                => 0,
      "msg"                => "",
      "is_lost"            => 0,
      "nickname"           => "Stanley",
      "gender"             => "男",
      "province"           => "北京",
      "city"               => "",
      "year"               => "1977",
      "figureurl"          => "http:\/\/qzapp.qlogo.cn\/qzapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/30",
      "figureurl_1"        => "http:\/\/qzapp.qlogo.cn\/qzapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/50",
      "figureurl_2"        => "http:\/\/qzapp.qlogo.cn\/qzapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/100",
      "figureurl_qq_1"     => "http:\/\/q.qlogo.cn\/qqapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/40",
      "figureurl_qq_2"     => "http:\/\/q.qlogo.cn\/qqapp\/101177565\/94BA192CE722DD1CB581A3A362BC255C\/100",
      "is_yellow_vip"      => "0",
      "vip"                => "0",
      "yellow_vip_level"   => "0",
      "level"              => "0",
      "is_yellow_year_vip" => "0"
    }
  end

end
