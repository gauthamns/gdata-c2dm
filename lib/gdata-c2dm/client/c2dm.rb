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
        body_hash = {}
        body_hash["registration_id"] = registration_id
        body_hash["collapse_key"] = collapse_key
        body_hash["delay_while_idle"] = delay_while_idle if delay_while_idle

        data_hash.each do |key, value|
          body_hash["data.#{key}"] = value
        end
        
        data =
          body_hash.map{|k, v| "&#{k}=#{URI.escape(v.to_s)}"}.reduce{|k, v| k + v}
        self.make_request(:post, @c2dm_url, data)
      end

      def prepare_headers
        headers = super
        headers['Authorization'] = "GoogleLogin auth=#{@token}"
        headers
      end
    end
  end
end