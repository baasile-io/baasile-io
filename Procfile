web: jemalloc.sh bundle exec puma -C config/puma.rb
worker: jemalloc.sh bundle exec sidekiq -q default -q mailers
release: bundle exec rails db:migrate
