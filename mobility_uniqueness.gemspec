# frozen_string_literal: true

require_relative "lib/mobility_uniqueness/version"

Gem::Specification.new do |spec|
  spec.name = "mobility_uniqueness"
  spec.version = MobilityUniqueness::VERSION
  spec.authors = ["“egemen_ozturk”"]
  spec.email = ["egemenwasd@gmail.com"]

  # Short summary for the gem's purpose
  spec.summary  = "Adds locale-specific uniqueness validation for translated attributes in Mobility."

  # More detailed description of what the gem does and why it's useful
  spec.description = <<-DESC
    MobilityUniqueness extends the Mobility gem with locale-specific uniqueness validation 
    for translated attributes in ActiveRecord models. It allows you to ensure that a given attribute, 
    such as `name` in different locales, is unique within the specified locale. 

    By using this validator, you can enforce uniqueness for translations without needing to write 
    complex custom validation code in your Rails models. The gem works seamlessly with Mobility’s 
    `KeyValue` backend to query translations and check for duplicates.
  DESC

  spec.homepage = "https://github.com/egemen-dev"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
