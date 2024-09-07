class MoodleApiService
  include HTTParty
  base_uri 'https://lms.cpucollege.edu.et/webservice/rest/server.php'

  def initialize(token)
    @token = token
  end

  def get_user_by_username(username)
    response = self.class.get('', query: {
      wstoken: @token,
      wsfunction: 'core_user_get_users',
      criteria: [{ key: 'username', value: username }],
      moodlewsrestformat: 'json'
    })

    if response.success?
      response.parsed_response
    else
      raise "Error: #{response['error']}"
    end
  end

  def generate_sso_url(user)
    # Example implementation of SSO URL generation
    sso_token = generate_sso_token(user)
    "https://lms.cpucollege.edu.et/login/index.php?authSSO=true&token=#{sso_token}"
  end

  private

  def generate_sso_token(user)
    # Implement SSO token generation logic here
    "generated_sso_token_for_#{user['id']}"
  end
end