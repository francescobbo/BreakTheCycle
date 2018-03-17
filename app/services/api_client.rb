class ApiClient
  BASE_ENDPOINT ="https://santander.openbankproject.com/obp/v3.0.0/"

  attr_reader :token

  def initialize(username, password)
    @username = username
    @password = password
    @consumer_key = Rails.application.credentials.obp[:consumer_key]
  end

  def current_user
    get('users/current', nil)
  end

  def get_accounts
    get('banks/santander.01.uk.sanuk/accounts-held', nil)
  end

  def get_transactions(account_id)
    get("my/banks/santander.01.uk.sanuk/accounts/#{account_id}/transactions")
  end

  private

  def token
    @token ||= authentication[:token]
  end

  def default_headers
    { 'Content-type': 'application/json' }
  end

  def auth_headers
    { 'Authorization': "DirectLogin token=\"#{token}\""}
  end

  def handle(response)
    if response.code / 100 == 2
      JSON.parse(response).with_indifferent_access
    else
      raise StandardError, "What the hell!"
    end
  end

  def get(endpoint, data = nil, headers = {})
    headers = default_headers.merge(auth_headers).merge(headers).merge(params: data)
    handle RestClient.get("#{BASE_ENDPOINT}/#{endpoint}", headers)
  end

  def post(endpoint, data = nil, headers = {})
    handle RestClient.post("#{BASE_ENDPOINT}/#{endpoint}", data, default_headers.merge(auth_headers).merge(headers))
  end

  def authentication
    handle RestClient.post('https://santander.openbankproject.com/my/logins/direct', nil, default_headers.merge({
      'Authorization': "DirectLogin username=\"#{@username}\", password=\"#{@password}\", consumer_key=\"#{@consumer_key}\""
    }))
  end
end
