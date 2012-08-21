# encoding: utf-8
require 'devise'
require 'oauth2'


require 'devise_oauth2_authenticatable/model' 
require 'devise_oauth2_authenticatable/strategy'
require 'devise_oauth2_authenticatable/schema'
require 'devise_oauth2_authenticatable/routes'
#require 'devise_oauth2_authenticatable/controller_filters'
require 'devise_oauth2_authenticatable/view_helpers'
require 'devise_oauth2_authenticatable/sessions_controller_extension.rb'


module Devise
  # Specifies the name of the database column name used for storing
  # the oauth UID. Useful if this info should be saved in a
  # generic column if different authentication solutions are used.
  
  
  mattr_accessor :oauth2_uid_field
  @@oauth2_uid_field = :oauth2_uid

  # Specifies the name of the database column name used for storing
  # the user Facebook session key. Useful if this info should be saved in a
  # generic column if different authentication solutions are used.
  mattr_accessor :oauth2_token_field
  @@oauth2_token_field = :oauth2_token

  # Specifies if account should be created if no account exists for
  # a specified Facebook UID or not.
  mattr_accessor :oauth2_auto_create_account
  @@oauth2_auto_create_account = true
  
  
  mattr_accessor :oauth2_callback_path
 	@@oauth2_callback_path = '/oauth_callback'
 	
  def self.oauth2_client
    @@oauth2_client ||= OAuth2::Client.new(OAUTH2_CONFIG[RAILS_ENV]['client_id'], OAUTH2_CONFIG[RAILS_ENV]['client_secret'], :site => OAUTH2_CONFIG[RAILS_ENV]['authorization_server'])
    puts @@oauth2_client.inspect
    @@oauth2_client
  end
  
  
  def self.session_sign_in_url(request, mapping, params = nil)
    url = URI.parse(URI.escape(request.url,/\|/))
    url.path = "#{mapping.parsed_path}/#{mapping.path_names[:sign_in]}"
    url.query = params
    url.to_s
  end
  
  def self.requested_scope
    @@requested_scope ||= ::OAUTH2_CONFIG[RAILS_ENV]['requested_scope']
  end
  
end

# Load core I18n locales: en
#
I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[devise_oauth2_authenticatable locales en.yml])

# Add +:facebook_connectable+ strategies to defaults.
#
Devise.add_module(:oauth2_authenticatable,
  :strategy => true,
  :controller => :sessions,
  :model => 'devise_oauth2_authenticatable/model')
  
  
#::Devise::SessionsController.send :include, ::Devise::Oauth2Authenticatable::SessionsControllerExtension