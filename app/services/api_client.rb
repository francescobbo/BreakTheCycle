class ApiClient
  HOST = 'https://santander.openbankproject.com/'
  USER ="https://santander.openbankproject.com/obp/v3.0.0/users"

  attr_reader :token

  def initialize
    @username = Rails.application.credentials.obp.username
    @password = Rails.application.credentials.obp.password
    @consumer_key = Rails.application.credentials.obp.consumer_key
  end

  def authentication
    post('my/logins/direct', nil, {
      'Authorization': "DirectLogin username=\"#{@username}\", password=\"#{@password}\", consumer_key=\"#{@consumer_key}\""
    })
  end

  def token
    @token ||= JSON.parse(authentication)
  end

  private

  def default_headers
    { 'Content-type': 'application/json' }
  end

  def post(endpoint, data, headers)
    RestClient.post("#{HOST}/#{endpoint}", data, default_headers.merge(headers))
  end
end
