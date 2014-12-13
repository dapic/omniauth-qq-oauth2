# encoding: utf-8
module OmniAuth
  module Strategies
    class QQ < OmniAuth::Strategies::OAuth2
      option :name, "qq"
      option :client_options, {
        :site          => 'https://graph.qq.com',
        :authorize_url => '/oauth2.0/authorize',
        :token_url     => "/oauth2.0/token"
      }
      option :authorize_params, {
        :response_type => "code"
      }

      option :token_params, {
        :parse => :query
      }

      uid do
        @openid ||= get_openid
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
        @raw_info ||= get_raw_info
      end

      def get_openid
        access_token.options[:mode] = :query
        response = access_token.get('/oauth2.0/me')
        matched = response.body.match(/"openid":"(?<openid>\w+)"/)
        matched[:openid]
      end

      def get_raw_info
        access_token.get('/user/get_user_info',
                         params: qq_openapi_params,
                         parse: :json)
        .parsed
      end

      def qq_openapi_params
        {
          :openid             => uid,
          :oauth_consumer_key => options[:client_id],
          :format             => :json
        }
      end
    end
  end
end
OmniAuth.config.add_camelization('qq', 'QQ')
