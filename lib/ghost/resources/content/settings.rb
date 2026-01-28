# frozen_string_literal: true

module Ghost
  module Resources
    module Content
      class Settings < Base
        actions :browse

        def resource_name
          "settings"
        end
      end
    end
  end
end
