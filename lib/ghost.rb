# frozen_string_literal: true

require_relative "ghost/version"
require_relative "ghost/errors"
require_relative "ghost/config"
require_relative "ghost/response"
require_relative "ghost/client"

require_relative "ghost/authentication/jwt_token"
require_relative "ghost/authentication/content_key"

require_relative "ghost/resources/base"

# Admin resources
require_relative "ghost/resources/admin/posts"
require_relative "ghost/resources/admin/pages"
require_relative "ghost/resources/admin/tags"
require_relative "ghost/resources/admin/members"
require_relative "ghost/resources/admin/users"
require_relative "ghost/resources/admin/newsletters"
require_relative "ghost/resources/admin/tiers"
require_relative "ghost/resources/admin/offers"
require_relative "ghost/resources/admin/webhooks"
require_relative "ghost/resources/admin/site"
require_relative "ghost/resources/admin/images"
require_relative "ghost/resources/admin/media"
require_relative "ghost/resources/admin/files"
require_relative "ghost/resources/admin/themes"

# Content resources
require_relative "ghost/resources/content/posts"
require_relative "ghost/resources/content/pages"
require_relative "ghost/resources/content/authors"
require_relative "ghost/resources/content/tags"
require_relative "ghost/resources/content/settings"
require_relative "ghost/resources/content/tiers"
require_relative "ghost/resources/content/newsletters"
require_relative "ghost/resources/content/offers"

require_relative "ghost/admin_api"
require_relative "ghost/content_api"
