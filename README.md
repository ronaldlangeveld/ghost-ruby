# ghost-ruby

Ruby SDK for the [Ghost](https://ghost.org/) API. Supports both the **Content API** (read-only, public data) and the **Admin API** (full CRUD, file uploads, member management).

Targets **Ghost v5** and **later** only.

## Installation

Add to your Gemfile:

```ruby
gem "ghost-ruby"
```

Then run `bundle install`. Or install directly:

```
gem install ghost-ruby
```

## Quick Start

```ruby
require "ghost-ruby"

# Content API - read-only access to public content
content = Ghost::ContentAPI.new(
  url: "https://your-site.ghost.io",
  key: "your-content-api-key",
  version: "v5.0"
)

posts = content.posts.browse(limit: 5, include: "authors,tags")
posts.each { |post| puts post["title"] }

# Admin API - full read/write access
admin = Ghost::AdminAPI.new(
  url: "https://your-site.ghost.io",
  key: "your-admin-id:your-admin-secret",
  version: "v5.0"
)

admin.posts.add(title: "Hello World", html: "<p>My first post!</p>")
```

## Finding Your API Keys

1. In Ghost Admin, go to **Settings > Integrations**
2. Create a custom integration (or use an existing one)
3. You'll see:
   - **Content API Key** - a 26-character hex string
   - **Admin API Key** - in the format `id:secret` (24-hex `:` 64-hex)

## Content API

The Content API provides read-only access to published content. Authentication uses the Content API key as a query parameter.

```ruby
ghost = Ghost::ContentAPI.new(
  url: "https://your-site.ghost.io",
  key: "your-content-api-key",
  version: "v5.0"  # optional, defaults to "v5.0"
)
```

### Browsing

Fetch multiple resources with optional filters, includes, and pagination:

```ruby
# Get all posts
posts = ghost.posts.browse

# With query parameters
posts = ghost.posts.browse(
  limit: 10,
  page: 2,
  include: "authors,tags",
  filter: "tag:getting-started",
  order: "published_at desc",
  fields: "title,slug,published_at"
)

# Iterate over results
posts.each { |post| puts post["title"] }

# Pagination info
posts.pagination
# => {"page"=>1, "limit"=>10, "pages"=>5, "total"=>42, "next"=>2, "prev"=>nil}
```

### Reading a Single Resource

Fetch by `id`, `slug`, or `email`:

```ruby
post = ghost.posts.read(id: "61a5c8...")
post = ghost.posts.read(slug: "hello-world")
post.first["title"]  # => "Hello World"

# With additional params
post = ghost.posts.read(id: "61a5c8...", include: "authors,tags")
```

### Available Content Resources

| Resource       | Actions         |
| -------------- | --------------- |
| `posts`        | browse, read    |
| `pages`        | browse, read    |
| `authors`      | browse, read    |
| `tags`         | browse, read    |
| `tiers`        | browse, read    |
| `newsletters`  | browse, read    |
| `offers`       | browse, read    |
| `settings`     | browse          |

```ruby
ghost.authors.browse
ghost.tags.read(slug: "news")
ghost.settings.browse
ghost.tiers.browse
ghost.newsletters.browse
ghost.offers.browse
```

## Admin API

The Admin API provides full CRUD access plus file uploads. Authentication uses JWT tokens signed with the Admin API key.

```ruby
ghost = Ghost::AdminAPI.new(
  url: "https://your-site.ghost.io",
  key: "your-admin-id:your-admin-secret",
  version: "v5.0"  # optional, defaults to "v5.0"
)
```

JWT tokens are generated automatically, cached, and refreshed before expiry.

### Creating Resources

```ruby
response = ghost.posts.add(
  title: "My New Post",
  html: "<p>Post content here.</p>",
  status: "draft",
  tags: [{ name: "News" }]
)

new_post = response.first
puts new_post["id"]  # => "64b5f7..."
```

### Updating Resources

```ruby
response = ghost.posts.edit(
  id: "64b5f7...",
  title: "Updated Title",
  updated_at: "2024-01-01T00:00:00.000Z"
)
```

Note: Ghost requires `updated_at` for edit operations to prevent conflicts. Include the value from the most recent read.

### Deleting Resources

```ruby
ghost.posts.delete(id: "64b5f7...")  # => true
```

### File Uploads

Upload images, media, files, and themes:

```ruby
# Upload an image
response = ghost.images.upload(file: "/path/to/photo.jpg")
image_url = response.first["url"]

# Upload with a reference
response = ghost.images.upload(file: "/path/to/photo.jpg", ref: "photo-ref")

# Upload media (video/audio)
ghost.media.upload(file: "/path/to/video.mp4")

# Upload generic files
ghost.files.upload(file: "/path/to/document.pdf")

# Upload a theme
ghost.themes.upload(file: "/path/to/theme.zip")
```

### Available Admin Resources

| Resource       | Actions                          |
| -------------- | -------------------------------- |
| `posts`        | browse, read, add, edit, delete  |
| `pages`        | browse, read, add, edit, delete  |
| `tags`         | browse, read, add, edit, delete  |
| `members`      | browse, read, add, edit, delete  |
| `newsletters`  | browse, read, add, edit          |
| `tiers`        | browse, read, add, edit          |
| `offers`       | browse, read, add, edit          |
| `users`        | browse, read                     |
| `webhooks`     | add, edit, delete                |
| `site`         | read                             |
| `images`       | upload                           |
| `media`        | upload                           |
| `files`        | upload                           |
| `themes`       | upload                           |

## Working with Responses

All browse, read, add, and edit methods return a `Ghost::Response` object:

```ruby
response = ghost.posts.browse(limit: 5)

response.data        # Array of resource hashes
response.first       # First resource hash
response.meta        # Meta hash (includes pagination)
response.pagination  # Pagination hash directly
response.raw         # The full raw JSON hash

# Ghost::Response is Enumerable
response.each { |post| puts post["title"] }
response.map { |post| post["slug"] }
response.to_a
response.count
```

## Error Handling

API errors raise typed exceptions that inherit from `Ghost::Error`:

```ruby
begin
  ghost.posts.read(id: "nonexistent")
rescue Ghost::NotFoundError => e
  puts e.message      # => "Resource not found"
  puts e.error_type   # => "NotFoundError"
  puts e.context      # => additional context from Ghost
  puts e.status_code  # => 404
rescue Ghost::Error => e
  # Catch-all for any Ghost API error
  puts e.message
end
```

| HTTP Status | Exception Class             |
| ----------- | --------------------------- |
| 400         | `Ghost::BadRequestError`    |
| 401         | `Ghost::AuthenticationError`|
| 403         | `Ghost::ForbiddenError`     |
| 404         | `Ghost::NotFoundError`      |
| 422         | `Ghost::UnprocessableError` |
| 500         | `Ghost::ServerError`        |

Configuration errors (missing URL, invalid key format) raise `Ghost::Error` immediately on initialization.

## Requirements

- Ruby >= 3.0
- Ghost v5+

## Development

```
git clone https://github.com/TryGhost/ghost-ruby.git
cd ghost-ruby
bundle install
bundle exec rspec
```

## License

MIT
