# frozen_string_literal: true

module Ghost
  module Resources
    module Admin
      class Tags < Base
        actions :browse, :read, :add, :edit, :delete
      end
    end
  end
end
