# frozen_string_literal: true

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
require_relative 'whatsrb_cloud/resources/sessions'
require_relative 'whatsrb_cloud/resources/messages'
require_relative 'whatsrb_cloud/resources/business_accounts'
require_relative 'whatsrb_cloud/resources/connects'
require_relative 'whatsrb_cloud/resources/business_messages'
require_relative 'whatsrb_cloud/resources/templates'
require_relative 'whatsrb_cloud/resources/webhooks'
require_relative 'whatsrb_cloud/resources/usage'
require_relative 'whatsrb_cloud/client'
require_relative 'whatsrb_cloud/webhook_signature'

module WhatsrbCloud
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
