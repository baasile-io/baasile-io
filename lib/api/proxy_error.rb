module Api
  class ProxyError < StandardError
    attr_reader :code
    attr_reader :req
    attr_reader :res
    attr_reader :uri
    attr_reader :message
    attr_reader :meta

    def initialize(data = {})
      data[:code] ||= 502
      @data = data
    end

    def code
      @data[:code].to_i
    end

    def req
      @data[:req]
    end

    def res
      @data[:res]
    end

    def uri
      @data[:uri]
    end

    def message
      @data[:message]
    end

    def meta
      @data[:meta]
    end
  end

  class BaseForbiddenError < ProxyError
    def code
      403
    end
  end

  class BaseNotFoundError < ProxyError
    def code
      404
    end
  end

  class ProxySSLError < ProxyError
    def code
      601
    end
  end

  class ProxySocketError < ProxyError
    def code
      602
    end
  end

  class ProxyRedirectionError < ProxyError
    def code
      603
    end
  end

  class ProxyAuthenticationError < ProxyError
    def code
      604
    end
  end

  class ProxyInitializationError < ProxyError
    def code
      605
    end
  end

  class ProxyMissingMandatoryQueryParameterError < ProxyError
    def code
      606
    end
  end

  class ProxyRequestError < ProxyError
    def code
      607
    end
  end

  class ProxyNotFoundError < ProxyError
    def code
      608
    end
  end

  class ProxyEOFError < ProxyError
    def code
      609
    end
  end

  class ProxyTimeoutError < ProxyError
    def code
      610
    end
  end

  class ProxyMethodNotAllowedError < ProxyError
    def code
      611
    end
  end

  class ProxyInvalidSecretSignatureError < ProxyError
    def code
      612
    end
  end

  class ProxyBadRequestError < ProxyError
    def code
      613
    end
  end

  class ProxyUnauthorizedError < ProxyError
    def code
      614
    end
  end

  class AuthInvalidClientIdError < ProxyError
    def code
      701
    end
  end

  class AuthMissingClientIdError < ProxyError
    def code
      702
    end
  end

  class AuthMissingClientSecretError < ProxyError
    def code
      703
    end
  end

  class AuthInactiveClientError < ProxyError
    def code
      704
    end
  end

  class AuthBadCredentialsError < ProxyError
    def code
      705
    end
  end

  class AuthMissingScopeError < ProxyError
    def code
      706
    end
  end

  class AuthInvalidRefreshTokenError < ProxyError
    def code
      707
    end
  end

  class AuthExpiredRefreshTokenError < ProxyError
    def code
      708
    end
  end

  class AuthMissingRefreshTokenError < ProxyError
    def code
      709
    end
  end

  class AuthMissingAuthorizationHeader < ProxyError
    def code
      710
    end
  end

  class AuthExpiredAccessTokenError < ProxyError
    def code
      711
    end
  end

  class AuthInvalidAccessTokenError < ProxyError
    def code
      712
    end
  end

  class AuthClientNotFoundError < ProxyError
    def code
      713
    end
  end

  class AuthInvalidScopeError < ProxyError
    def code
      714
    end
  end

  class ContractMissingContractError < ProxyError
    def code
      801
    end
  end

  class ContractNotValidatedContractError < ProxyError
    def code
      802
    end
  end

  class ContractMissingStartDateProductionPhaseError < ProxyError
    def code
      803
    end
  end

  class ContractNotStartedProductionPhaseError < ProxyError
    def code
      804
    end
  end

  class ContractEndedProductionPhaseError < ProxyError
    def code
      805
    end
  end

  class ContractWaitingForProductionError < ProxyError
    def code
      806
    end
  end

  class ContractNotActiveError < ProxyError
    def code
      807
    end
  end

  class OtherNotActiveSupplierError < ProxyError
    def code
      901
    end
  end
end