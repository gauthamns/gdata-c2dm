module GData
  module Client

    class C2dm < Base

      # Google auth token.
      attr_accessor :token

      # Url to which c2dmessage has to be sent.
      attr_accessor :c2dm_url

      def initialize(options = {})
        options[:clientlogin_service] ||= 'ac2dm'
        super(options)

        @c2dm_url = "https://android.apis.google.com/c2dm/send"
      end

      # Set the clientlogin token if present.
      def set_clientlogin_token(auth_token)
        @token = auth_token
      end

      def send_c2dmessage(registration_id, collapse_key, delay_while_idle, data_hash)
        body = data_hash
        body["registration_id"] = registration_id
        body["collapse_key"] = collapse_key
        body["delay_while_idle"] = delay_while_idle if delay_while_idle
        body["AUTH_TOKEN"] = auth_token

        self.make_request(:post, @c2dm_url, body)
      end

      def prepare_headers
        headers = super.prepare_headers
        headers['Authorization: GoogleLogin auth'] = @token
        headers
      end
    end
  end
end