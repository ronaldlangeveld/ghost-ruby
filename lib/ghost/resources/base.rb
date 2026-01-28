# frozen_string_literal: true

module Ghost
  module Resources
    class Base
      class << self
        def actions(*action_names)
          @defined_actions = action_names

          action_names.each do |action|
            case action
            when :browse then define_browse
            when :read then define_read
            when :add then define_add
            when :edit then define_edit
            when :delete then define_delete
            when :upload then define_upload
            end
          end
        end

        def defined_actions
          @defined_actions || []
        end

        def resource_name
          name.split("::").last.downcase
        end

        private

        def define_browse
          define_method(:browse) do |**params|
            url = @config.resource_url(resource_name)
            body = @client.get(url, params)
            Ghost::Response.new(body)
          end
        end

        def define_read
          define_method(:read) do |**params|
            url = if params[:id]
                    @config.resource_id_url(resource_name, params.delete(:id))
                  elsif params[:slug]
                    @config.resource_slug_url(resource_name, params.delete(:slug))
                  elsif params[:email]
                    @config.resource_email_url(resource_name, params.delete(:email))
                  else
                    raise Ghost::Error, "read requires an id, slug, or email"
                  end

            body = @client.get(url, params)
            Ghost::Response.new(body)
          end
        end

        def define_add
          define_method(:add) do |**params|
            url = @config.resource_url(resource_name)
            payload = { resource_name => [params] }
            body = @client.post(url, payload)
            Ghost::Response.new(body)
          end
        end

        def define_edit
          define_method(:edit) do |**params|
            id = params.delete(:id) || raise(Ghost::Error, "edit requires an id")
            url = @config.resource_id_url(resource_name, id)
            payload = { resource_name => [params] }
            body = @client.put(url, payload)
            Ghost::Response.new(body)
          end
        end

        def define_delete
          define_method(:delete) do |**params|
            id = params.delete(:id) || raise(Ghost::Error, "delete requires an id")
            url = @config.resource_id_url(resource_name, id)
            @client.delete(url)
            true
          end
        end

        def define_upload
          define_method(:upload) do |file:, ref: nil|
            url = @config.resource_url(resource_name) + "upload/"
            body = @client.upload(url, file, ref: ref)
            Ghost::Response.new(body)
          end
        end
      end

      def initialize(client:, config:)
        @client = client
        @config = config
      end

      private

      def resource_name
        self.class.resource_name
      end
    end
  end
end
