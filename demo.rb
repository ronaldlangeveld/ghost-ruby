# frozen_string_literal: true

require_relative "lib/ghost-ruby"

# ─── Configuration ──────────────────────────────────────────
GHOST_URL       = "https://your-site.ghost.io"
CONTENT_API_KEY = "your-content-api-key"
ADMIN_API_KEY   = "your-admin-id:your-admin-secret"
# ────────────────────────────────────────────────────────────

puts "=== Content API ==="
content = Ghost::ContentAPI.new(url: GHOST_URL, key: CONTENT_API_KEY)

puts "\n-- Browse posts --"
posts = content.posts.browse(limit: 3, include: "authors,tags")
posts.each do |post|
  author = post.dig("authors", 0, "name") || "Unknown"
  tags = (post["tags"] || []).map { |t| t["name"] }.join(", ")
  puts "  #{post["title"]} (by #{author}) [#{tags}]"
end
puts "  Total: #{posts.pagination["total"]}, Page: #{posts.pagination["page"]}/#{posts.pagination["pages"]}"

puts "\n-- Read post by slug --"
if posts.first
  slug = posts.first["slug"]
  post = content.posts.read(slug: slug)
  puts "  Title: #{post.first["title"]}"
  puts "  Excerpt: #{post.first["excerpt"]&.slice(0, 100)}..."
end

puts "\n-- Browse tags --"
tags = content.tags.browse(limit: 5)
tags.each { |tag| puts "  #{tag["name"]} (#{tag["slug"]})" }

puts "\n-- Browse authors --"
authors = content.authors.browse(limit: 5)
authors.each { |a| puts "  #{a["name"]}" }

puts "\n\n=== Admin API ==="
admin = Ghost::AdminAPI.new(url: GHOST_URL, key: ADMIN_API_KEY)

puts "\n-- Create a draft post --"
response = admin.posts.add(
  title: "Test Post from ghost-ruby",
  html: "<p>This post was created by the ghost-ruby SDK.</p>",
  status: "draft"
)
new_post = response.first
puts "  Created: #{new_post["title"]} (id: #{new_post["id"]})"

puts "\n-- Update the post --"
response = admin.posts.edit(
  id: new_post["id"],
  title: "Updated Test Post from ghost-ruby",
  updated_at: new_post["updated_at"]
)
updated_post = response.first
puts "  Updated: #{updated_post["title"]}"

puts "\n-- Delete the post --"
admin.posts.delete(id: updated_post["id"])
puts "  Deleted successfully"

puts "\n-- Browse members --"
members = admin.members.browse(limit: 3)
members.each { |m| puts "  #{m["name"] || m["email"]}" }
puts "  Total members: #{members.pagination["total"]}"

puts "\nDone!"
