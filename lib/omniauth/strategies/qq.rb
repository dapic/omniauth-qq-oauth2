# encoding: utf-8
require 'omniauth/strategies/oauth2'
module Omniauth
    module Strategies
        class QQ < OmniAuth::Strategies::OAuth2
            option :name, "qq"
            option :client_options, {
                :site => 'https://graph.qq.com/oauth2.0/',
                :authorize_url => '/oauth2.0/authorize',
                :token_url => "/oauth2.0/token"
            }
            option :token_params, {
                :state => 'foobar',
                :parse => :query
            }
            uid do
                @uid ||= begin
                             access_token.options[:mode] = :query
                             access_token.options[:param_name] = :access_token
                             response = access_token.get('/oauth2.0/me')
                             matched = response.body.match(/"openid":"(?<openid>\w+)"/)
                             matched[:openid]
                         end
            end
            info do 
                { 
                    :nickname => raw_info['nickname'],
                    :name => raw_info['nickname'],
                    :image => raw_info['figureurl_1'],
                }
            end
            extra do
                {
                    :raw_info => raw_info
                }
            end

            def raw_info
                @raw_info ||= begin
                                  client.request(:get, "https://graph.qq.com/user/get_user_info", :params => {
                                      :format => :json,
                                      :openid => uid,
                                      :oauth_consumer_key => options[:client_id],
                                      :access_token => access_token.token
                                  }, :parse => :json).parsed
                              end
            end
        end
    end
end
OmniAuth.config.add_camelization('qq', 'QQ')
