# frozen_string_literal: true

require 'cgi'
require 'time'

require_relative 'whatsrb_cloud/version'
require_relative 'whatsrb_cloud/configuration'
require_relative 'whatsrb_cloud/errors'
require_relative 'whatsrb_cloud/connection'
require_relative 'whatsrb_cloud/objects/list'
require_relative 'whatsrb_cloud/objects/session'
require_relative 'whatsrb_cloud/objects/message'
require_relative 'whatsrb_cloud/objects/business_account'
require_relative 'whatsrb_cloud/objects/connect_request'
require_relative 'whatsrb_cloud/objects/template'
require_relative 'whatsrb_cloud/objects/webhook'
require_relative 'whatsrb_cloud/payload_schema'
require_relative 'whatsrb_cloud/objects/agent'
require_relative 'whatsrb_cloud/objects/agent_run'
require_relative 'whatsrb_cloud/resources/sessions'
require_relative 'whatsrb_cloud/resources/messages'
require_relative 'whatsrb_cloud/resources/business_accounts'
require_relative 'whatsrb_cloud/resources/connects'
require_relative 'whatsrb_cloud/resources/business_messages'
require_relative 'whatsrb_cloud/resources/templates'
require_relative 'whatsrb_cloud/resources/webhooks'
require_relative 'whatsrb_cloud/resources/usage'
require_relative 'whatsrb_cloud/resources/agents'
require_relative 'whatsrb_cloud/resources/agent_runs'
require_relative 'whatsrb_cloud/client'
require_relative 'whatsrb_cloud/webhook_signature'
require_relative 'whatsrb_cloud/event_registry'
require_relative 'whatsrb_cloud/action_registry'

module WhatsrbCloud
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      @client ||= Client.new
    end

    def reset_configuration!
      @configuration = Configuration.new
      @client = nil
    end
  end
end
