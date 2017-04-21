class LoadAppconfigsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if Thread.current[:appconfigs_updated_at].nil? || Thread.current[:appconfigs_updated_at] < Appconfig.last_updated_at
      Thread.current[:appconfigs] = Appconfig.reload_config
    end
    @app.call(env)
  end
end
