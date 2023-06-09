# Be sure to restart your server when you modify this file.

Rails.application.config.assets.enabled = true
Rails.application.config.assets.initialize_on_precompile = false

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w( diagram.js graphing.js map_marker.js ace.js tweets.js )

Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
Rails.application.config.assets.precompile += %w(*.woff *.eot *.svg *.ttf) # Bootstrap fonts
