class CatchErrorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionDispatch::ParamsParser::ParseError => error
      if env['HTTP_ACCEPT'] =~ /application\/json/
        return [400, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 400,
                                                                    title: 'Malformed JSON request.'
                                                                  }
                                                                ]
                                                              }.to_json]]
      else
        return [400, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 400,
                                                                    title: 'Malformed request. Please verify your mime type (Accept and / or Content-Type).'
                                                                  }
                                                                ]
                                                              }.to_json]]
      end
    rescue Api::ProxyError => error
      status = I18n.t("errors.api.#{error.code}.status", locale: :en).to_i
      error_json = {
        code: error.code,
        title: I18n.t("errors.api.#{error.code}.title", locale: :en),
        message: I18n.t("errors.api.#{error.code}.message", locale: :en)
      }
      error_json[:meta] = error.meta if error.meta
      if status == 0
        Airbrake.notify('Misconfigured error', {
          error: error.class,
          message: error.message
        })
        status = 500
      end
      return [status, {'Content-Type' => 'application/json'}, [{
                                                              errors: [
                                                                error_json
                                                              ]
                                                            }.to_json]]
    end
  end
end