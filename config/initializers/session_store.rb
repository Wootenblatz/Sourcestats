# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sourcestats.com_session',
  :secret      => '722eda564093effa8c7d05e4334aee987f08123f653861b910a80bf2711b4ec9303bca7635bab93b332c222ca8fcc7171b097c18884fe147bc67b373b3a9bda4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
