module ActionDispatch
  module Http
    # Provides access to the request's HTTP headers from the environment.
    #
    #   env     = { "CONTENT_TYPE" => "text/plain" }
    #   headers = ActionDispatch::Http::Headers.new(env)
    #   headers["Content-Type"] # => "text/plain"
    class Headers
      CGI_VARIABLES = %w(
        CONTENT_TYPE CONTENT_LENGTH
        HTTPS AUTH_TYPE GATEWAY_INTERFACE
        PATH_INFO PATH_TRANSLATED QUERY_STRING
        REMOTE_ADDR REMOTE_HOST REMOTE_IDENT REMOTE_USER
        REQUEST_METHOD SCRIPT_NAME
        SERVER_NAME SERVER_PORT SERVER_PROTOCOL SERVER_SOFTWARE
      )
      HTTP_HEADER = /\A[A-Za-z0-9-]+\z/

      include Enumerable
      attr_reader :env

      def initialize(env = {}) # :nodoc:
        @env = env
      end

      # Returns the value for the given key mapped to @env.
      def [](key)
        @env[env_name(key)]
      end

      # Set the given value for the key mapped to @env.
      def []=(key, value)
        @env[env_name(key)] = value
      end

      def key?(key); @env.key? key; end
      alias :include? :key?


      # Returns the value for the given key mapped to @env.
      # If the key can’t be found, there are several options:
      # with no other arguments, it will raise an KeyError exception;
      # If the optional code block is specified, then that will be run and its
      # result returned.
      def fetch(key, *args, &block)
        @env.fetch env_name(key), *args, &block
      end

      def each(&block)
        @env.each(&block)
      end


      # Returns a new Http::Headers instance containing the contents of
      # <tt>headers_or_env</tt> and the original instance.
      def merge(headers_or_env)
        headers = Http::Headers.new(env.dup)
        headers.merge!(headers_or_env)
        headers
      end

      # Adds the contents of <tt>headers_or_env</tt> to original instance
      # entries with duplicate keys are overwritten with the values from
      # <tt>headers_or_env</tt>.
      def merge!(headers_or_env)
        headers_or_env.each do |key, value|
          self[env_name(key)] = value
        end
      end

      private
      # Converts a HTTP header name to an environment variable name if it is
      # not contained within the headers hash.
      def env_name(key)
        key = key.to_s
        if key =~ HTTP_HEADER
          key = key.upcase.tr('-', '_')
          key = "HTTP_" + key unless CGI_VARIABLES.include?(key)
        end
        key
      end
    end
  end
end
