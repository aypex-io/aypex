require_relative "lib/aypex/version"

Gem::Specification.new do |spec|
  spec.name = "aypex"
  spec.version = Aypex::VERSION
  spec.authors = ["Matthew Kennedy"]
  spec.email = ["m.kennedy@me.com"]
  spec.homepage = "https://aypex.io"
  spec.summary = "Aypex the centerpiece for Aypex Commerce"
  spec.description = "Aypex Models, Helpers, Services and libraries"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aypex-io/aypex/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "https://github.com/aypex-io/aypex/releases/tag/v#{spec.version}"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.require_path = "lib"
  spec.required_ruby_version = ">= 3.2"

  %w[
    actionpack actionview activejob activemodel activerecord
    activestorage activesupport railties
  ].each do |rails_gem|
    spec.add_dependency rails_gem, ">= 7.0"
  end

  spec.add_dependency "activemerchant"
  spec.add_dependency "active_text"
  spec.add_dependency "active_storage_validations"
  spec.add_dependency "activerecord-typedstore"
  spec.add_dependency "acts_as_list"
  spec.add_dependency "auto_strip_attributes"
  spec.add_dependency "awesome_nested_set"
  spec.add_dependency "carmen"
  spec.add_dependency "cancancan"
  spec.add_dependency "friendly_id"
  spec.add_dependency "highline"
  spec.add_dependency "image_processing"
  spec.add_dependency "mini_magick" # used by active_storage_validations for dimensions
  spec.add_dependency "kaminari"
  spec.add_dependency "money"
  spec.add_dependency "monetize"
  spec.add_dependency "paranoia"
  spec.add_dependency "ransack"
  spec.add_dependency "rexml"
  spec.add_dependency "ruby-vips"
  spec.add_dependency "state_machines-activerecord"
  spec.add_dependency "state_machines-activemodel"
  spec.add_dependency "stringex"
  spec.add_dependency "twitter_cldr"
end
