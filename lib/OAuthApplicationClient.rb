require 'oauth2'

# Constants
REFRESH_TOKEN_DURATION = 55;

class OAuthApplicationClient < OAuth2::Client
  attr_accessor :token, :user_agent

  def initialize(client_id, client_secret, site, token_url, code)
    @client_id = client_id
    @client_secret = client_secret
    @site = site
    @token_url = token_url
    @auth_code = code
    @token = nil
    @user_agent = nil

    super(@client_id, @client_secret, site: @site, token_url: @token_url)
  end

  def get(path, params, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    @token.get(path, params: params, headers: headers, &block)
  end

  def put(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    headers.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.put(path, params: params, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def post(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    headers.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.post(path, params: params, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def post_file(endpoint, file=nil, params={})
    if isAccessTokenExpired?
      fetch_access_token()
    end
    url = URI.parse(@site + endpoint)

    File.open(file) do |f|
      additional_params = params.merge({'file' => UploadIO.new(f, 'application/EDI-X12', file)})
      req = Net::HTTP::Post::Multipart.new(url.path, additional_params)

      req['Authorization'] = "Bearer #{self.token.token}"
      req['User-Agent'] = @user_agent

      @response = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
      JSON.parse(@response.body)
    end
  end

  def delete(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    @token.delete(path, params: params, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def fetch_access_token()
    @token = self.client_credentials.get_token(headers: { 'Authorization' => 'Basic' })
  end

  # Returns a standard set of headers to be passed along with all requests
  def headers(additional_headers = {})
    { 'User-Agent' => @user_agent }.merge(additional_headers)
  end

  def isAccessTokenExpired?
    if !@token.is_a?(OAuth2::AccessToken)
      return true
    end
    @token.expired?
  end
end