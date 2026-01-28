# frozen_string_literal: true

module Ghost
  module Resources
    module Admin
      class Media < Base
        actions :upload

        def resource_name
          "media"
        end
      end
    end
  end
end
