require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::App

  require 'rack/app/version'
  require 'rack/app/constants'

  require 'rack/app/utils'
  require 'rack/app/file'

  require 'rack/app/params'
  require 'rack/app/router'
  require 'rack/app/endpoint'
  require 'rack/app/serializer'
  require 'rack/app/error_handler'
  require 'rack/app/endpoint/not_found'
  require 'rack/app/request_configurator'

  class << self

    def call(request_env)
      Rack::App::RequestConfigurator.configure(request_env)
      endpoint = router.fetch_endpoint(
          request_env['REQUEST_METHOD'],
          request_env[Rack::App::Constants::NORMALIZED_REQUEST_PATH])
      endpoint.call(request_env)
    end

    def description(*description_texts)
      @last_description = description_texts.join("\n")
    end

    alias desc description

    def get(path = '/', &block)
      add_route('GET', path, &block)
    end

    def post(path = '/', &block)
      add_route('POST', path, &block)
    end

    def put(path = '/', &block)
      add_route('PUT', path, &block)
    end

    def head(path = '/', &block)
      add_route('HEAD', path, &block)
    end

    def delete(path = '/', &block)
      add_route('DELETE', path, &block)
    end

    def options(path = '/', &block)
      add_route('OPTIONS', path, &block)
    end

    def patch(path = '/', &block)
      add_route('PATCH', path, &block)
    end

    def root(endpoint_path)
      normalized_path = Rack::App::Utils.normalize_path(endpoint_path)

      options '/' do
        endpoint = self.class.router.fetch_endpoint('OPTIONS', normalized_path)
        endpoint.get_response_body(request, response)
      end
      get '/' do
        endpoint = self.class.router.fetch_endpoint('GET', normalized_path)
        endpoint.get_response_body(request, response)
      end
    end

    def error(*exception_classes, &block)
      @error_handler ||= Rack::App::ErrorHandler.new
      unless block.nil?
        @error_handler.register_handler(exception_classes, block)
      end

      return @error_handler
    end

    def router
      @router ||= Rack::App::Router.new
    end

    def add_route(request_method, request_path, &block)

      request_path = ::Rack::App::Utils.join(@namespaces, request_path)

      properties = endpoint_properties.merge(
          {
              :user_defined_logic => block,
              :request_method => request_method,
              :request_path => request_path,
          }
      )

      endpoint = Rack::App::Endpoint.new(properties)
      router.register_endpoint!(request_method, request_path, @last_description, endpoint)

      @last_description = nil
      return endpoint

    end

    def serve_files_from(relative_path, options={})
      options.merge!(endpoint_properties)
      file_server = Rack::App::File::Server.new(relative_path, options)
      request_path = Rack::App::Utils.join(@namespaces, file_server.namespace, '**', '*')
      router.register_endpoint!('GET', request_path, @last_description, file_server)
      @last_description = nil
    end

    def mount(api_class,mount_prop={})

      unless api_class.is_a?(Class) and api_class <= Rack::App
        raise(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

      merge_prop = {:namespaces => [@namespaces,mount_prop[:to]].flatten}
      router.merge_router!(api_class.router, merge_prop)

      return nil
    end

    def serializer(&definition_how_to_serialize)
      @serializer ||= Rack::App::Serializer.new

      unless definition_how_to_serialize.nil?
        @serializer.set_serialization_logic(definition_how_to_serialize)
      end

      return @serializer
    end

    def headers(new_headers=nil)
      @headers ||= {}
      @headers.merge!(new_headers) if new_headers.is_a?(Hash)
      @headers
    end

    def namespace(request_path_namespace)
      return unless block_given?
      @namespaces ||= []
      @namespaces.push(request_path_namespace)
      yield
      @namespaces.pop
      nil
    end

    protected

    def endpoint_properties
      {
          :default_headers => headers,
          :error_handler => error,
          :description => @last_description,
          :serializer => serializer,
          :app_class => self
      }
    end

  end

  def params
    @__params__ ||= Rack::App::Params.new(request.env).to_hash
  end

  attr_writer :request, :response

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

  def payload
    @__payload__ ||= lambda {
      return nil unless @request.body.respond_to?(:gets)

      payload = ''
      while chunk = @request.body.gets
        payload << chunk
      end
      @request.body.rewind

      return payload
    }.call
  end

end