class FyberClient
  include HTTParty
  base_uri 'http://api.sponsorpay.com/feed/v1/offers.json'
  debug_output $stdout

  def initialize(args={})
    @query = Rails.application.secrets.fyber["configuration"].dup
    @query[:timestamp] = Time.now.to_i
    @query[:uid] = args[:uid]
    @query[:pub0] = args[:pub] unless args[:pub0].blank?
    @query[:page] = args[:page] unless args[:page].blank?

    @query[:hashkey] = sign_with_api_key(@query)
  end

  def get
    @response = self.class.get("/", query: @query)
    @body = @response.parsed_response
    self
  end

  def offers
    valid? ? @body["offers"] : []
  end

  def message
    @body["message"]
  end

  def valid?
    @response.headers["x-sponsorpay-response-signature"] == sign_with_api_key(@response.body)
  end

  private
  def sign_with_api_key(hash_or_string)
    api_key = Rails.application.secrets.fyber["api_key"]

    string = if hash_or_string.is_a? Hash
      hash_or_string.reject { |k, v| v.nil? }.to_query << "&"
    else
      hash_or_string
    end

    Digest::SHA1.hexdigest "#{string}#{api_key}"
  end
end
