require './app'
require 'rack/cors'
run 1
use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
    end
  end
Test::API.compile!
run Test::API