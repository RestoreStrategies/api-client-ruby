# frozen_string_literal: true

require 'net/http'
require 'uri'

module RestoreStrategies
  # Restore Strategies client
  class Client
    attr_reader :entry_point, :response

    # Initialize the Restore Strategies client
    #
    # * token: a user token
    # * secret: a user secret
    # * (optional) url: a valid URL
    # * (optional) port: a valid TCP port
    #
    def initialize(token, secret, url = nil, port = nil)
      @entry_point = '/api'
      @token = token
      @secret = secret
      @response = nil

      if url
        uri = URI(url)
        @host = uri.host

        @port = if port.nil?
                  if uri.scheme == 'https'
                    443
                  else
                    80
                  end
                else
                  port
                end
      else
        @host = 'api.restorestrategies.org'
        @port = port || 80
      end

      @credentials = { id: @token, key: @secret, algorithm: 'sha256' }
      RestoreStrategies.client = self
    end

    def get_item(path, id)
      api_request("#{path}/#{id}", 'GET')
    end

    def delete_item(path, id)
      api_request("#{path}/#{id}", 'DELETE')
    end

    def list_items(path)
      api_request(path, 'GET')
    end

    def search(params)
      params_str = params_to_string(params)
      api_request("/api/search?#{params_str}", 'GET')
    end

    def get_signup(id)
      href = "/api/opportunities/#{id}/signup"
      api_request(href, 'GET')
    end

    def post_item(path, payload)
      api_request(path, 'POST', payload)
    end

    private

    def api_request(path, verb, payload = nil)
      verb = verb.downcase
      header = request_header(path, verb, payload)
      http = Net::HTTP.new(@host, @port)
      http.use_ssl = true if @port == 443

      response = if verb == 'post'
                   http.post(path, payload, header)
                 elsif verb == 'delete'
                   http.delete(path, header)
                 else
                   http.get(path, header)
                 end

      @response = response
      response_case(response)
    end

    def request_header(path, verb, payload = nil)
      auth = Hawk::Client.build_authorization_header(
        credentials: @credentials,
        ts: Time.now,
        method: verb,
        request_uri: path,
        host: @host,
        port: @port,
        payload: payload,
        nonce: SecureRandom.uuid[0..5]
      )

      {
        'Content-type' => 'application/vnd.collection+json',
        'api-version' => '1',
        'Authorization' => auth,
        'User-agent' => "Ruby Client/#{RestoreStrategies::VERSION}"
      }
    end

    # rubocop:disable CyclomaticComplexity
    def response_case(response)
      case response.code
      when '500'
        # internal server error
        raise InternalServerError.new(response), '500 internal server error'
      when /^5/
        # 5xx server side error
        raise ServerError.new(response), '5xx level, server side error'
      when '400'
        # bad request
        raise RequestError.new(response), '400 error, bad request'
      when '401'
        # unauthorized
        raise UnauthorizedError.new(response), '401 error, unauthorized'
      when '403'
        # forbidden
        raise ForbiddenError.new(response), '403 error, forbidden'
      when '422'
        raise UnprocessableEntityError.new(response), '422 Unprocessable Entity'
      when /(?!(^404$))^4[0-9]+/
        # 4xx client side error
        raise ClientError.new(response, "client side #{response.code} error"),
              "client side #{response.code} error"
      else
        Response.new(response, response.body)
      end
    end
    # rubocop:enable CyclomaticComplexity

    def params_to_string(params)
      query = []
      return nil unless params.is_a? Hash

      params.each do |key, value|
        format_value(query, key, value)
      end

      query.join('&')
    end

    def format_value(query, key, value)
      if (value.is_a? Hash) || (value.is_a? Array)
        value.each do |sub_value|
          value = if sub_value.is_a? Numeric
                    sub_value.to_s
                  else
                    CGI.escape(sub_value)
                  end

          query.push("#{key}[]=#{value}")
        end
      else
        query.push("#{key}=" +
          (value.is_a?(Numeric) ? value.to_s : CGI.escape(value.to_s)))
      end
    end

    def get_rel_href(rel, json_obj)
      return get_rel_href_helper(rel, json_obj) unless json_obj.is_a? Array

      json_obj.each do |data|
        href = get_rel_href_helper(rel, data)
        return href unless href.nil?
      end

      nil
    end

    def get_rel_href_helper(rel, json_obj)
      return json_obj['href'] if json_obj['rel'] == rel
      nil
    end
  end
end
