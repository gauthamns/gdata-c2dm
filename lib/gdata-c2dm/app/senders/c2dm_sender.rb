# Used to send C2dMessages.

class C2dmSender

  # Specifies the collapse key in C2dm which signifies grouping. Only latest msg with collapse key
  # will be sent by C2dm
  attr_accessor :collapse_key;
  attr_accessor :registration_ids
  attr_accessor :data
  attr_accessor :delay_while_idle
  attr_accessor :auth_token
  attr_accessor :google_service


  def notification(message)
    @registration_ids = message.receivers
    @data_hash = Hash.new

    # TODO: We should not have C2DM related coding here. Need to remove data.
    @data_hash['body'] = message.body
    @data_hash['message_id'] = message.id.to_s
    @data_hash['service_id'] = message.service_id.to_s
    @data_hash['timestamp'] = Time.now.to_s

    # Return Self object.
    self

  end

  def deliver
    @registration_ids.each do |registration_id|
      deliver_each registration_id
    end
  end

  # This is used to deliver to a single device.
  def deliver_each(registration_id)
    is_sent = false
    # Duration for sleeping

    while (!is_sent)
      begin
        response =
                get_c2dm.send_c2dmessage(nil, @collapse_key, @delay_while_idle, @data_hash)
        is_sent = true
      rescue GData::Client::AuthorizationError
        # The AUTH Login is wrong. Generate a new auth login.
        refresh_auth_token
      rescue GData::Client::ServerError
        # Nothing simply retry after sleeping for 3 secs.
        sleep @sleep_sec * 3
        @sleep_sec += 1

      rescue GData::Client::InvalidRegistrationError
        response = $!.response
        # TODO: Need to remove the registration_id and escape sending.
        is_sent = true
      rescue GData::Client::QuotaExceededError
        response = $!.response
        # Inform admin. Escape sending.
        is_sent = true
      rescue GData::Client::DeviceQuotaExceededError
        # Inform admin. Escape sending.
        is_sent = true
      rescue GData::Client::MissingRegistrationError
        # Should not happen. Raise the request. Escape sending.
        is_sent = true
      rescue GData::Client::MismatchSenderIdError
        # Should not happen. Raise the request. Abort sending.
        raise StandardError
      rescue GData::Client::MessageTooBigError
        # Should not happen. Trim the body and resend.
        @data_hash['body'] = @data_hash['body'][0..150]
      rescue GData::Client::MissingCollapseKeyError
        # Set the collapse key and retry.
        @collapse_key = 'fastinfo'
      end
    end

  end

  def notification_message(data, registration_ids)
    self.data = data

    unless registration_ids.kind_of? Array
      raise Exception "Registration ids should be an array."
    end
    self.regisration_ids = registration_ids
  end

  # This function is to find and store clientauth token. If not present, it will get one and store in db.
  def fetch_auth_token
    google_data = GoogleInfo.find_or_initialize_by(username: username, google_service: google_service)
    unless google_data.persisted?
      # Not persisted. So create a client auth token and persist.
      google_data.clientauth_token =
              get_c2dm.clientlogin(username, password, nil, nil, google_service)
      google_data.save!
    end
    @auth_token = google_data.clientauth_token
  end

  def refresh_auth_token
    google_data = GoogleInfo.find_or_initialize_by(username: username, google_service: google_service)
    google_data.clientauth_token =
            get_c2dm.clientlogin(username, password, nil, nil, google_service)
    google_data.save!
    @auth_token = google_data.clientauth_token
  end

  def initialize
    # Initialize variables.
    @collapse_key = "fastinfo"
    @delay_while_idle = false
    @google_service = 'ac2dm'
    @config = YAML::load(ERB.new(IO.read(
                                         File.join(Rails.root, 'config', 'initializers', 'google_data.yml'))).result)[Rails.env]
    fetch_auth_token
    @sleep_sec = 1
  end

  def method_missing(name, *args, &block)
    @config[name.to_s]
  end

  def get_c2dm
    if @c2dm.nil?
      @c2dm = GData::Client::C2dm.new()
      @c2dm.set_clientlogin_token(@auth_token)
    end
    @c2dm
  end
end