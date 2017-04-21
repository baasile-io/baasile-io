class CatchJsonParseErrorsMiddleware
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
    end
  end
end