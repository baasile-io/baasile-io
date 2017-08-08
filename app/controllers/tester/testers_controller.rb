module Tester
  class TestersController < ApplicationController
    before_action :authenticate_user!
    #before_action :authorize_superadmin!
    before_action :load_clients, only: [:select_client, :select_proxy]

    layout 'tester'

    def index

    end

    def select_client

    end

    def select_proxy
      load_contracted_proxies
      @logotype_service = LogotypeService.new
    end

    private

    def load_contracted_proxies
      @proxies = current_client.contracts_as_client.map do |contract|
        if contract.status.to_sym == :validation || contract.status.to_sym == :validation_production
          contract.proxy
        end
      end.reject(&:blank?).uniq
    end

    def authorize_superadmin!
      return head(:forbidden) unless current_user.is_superadmin?
    end

    def current_client
      @client = @clients.find_by(id: params[:id]) if params[:id].present?
    end

    def load_clients
      @clients = (current_service.nil? ? current_user.services.clients_or_startups : current_service.children.clients_or_startups)
    end

    def current_module
      'tester'
    end
  end
end
