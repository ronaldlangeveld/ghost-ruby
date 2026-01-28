# frozen_string_literal: true

module Ghost
  module Resources
    module Admin
      class Site < Base
        actions :read

        def resource_name
          "site"
        end
      end
    end
  end
end
