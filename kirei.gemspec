# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kirei}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ardie Saeidi"]
  s.date = %q{2011-03-28}
  s.description = %q{HTML sanitizer}
  s.email = %q{ardalan.saeidi@gmail.com}
  s.extra_rdoc_files = ["lib/kirei.rb", "lib/kirei/config.rb", "lib/kirei/processors/clean_node.rb", "lib/kirei/version.rb"]
  s.files = ["Manifest", "Rakefile", "kirei.gemspec", "lib/kirei.rb", "lib/kirei/config.rb", "lib/kirei/processors/clean_node.rb", "lib/kirei/version.rb", "test/kirei_spec.rb"]
  s.homepage = %q{http://github.com/seppuku}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Kirei"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{kirei}
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{HTML sanitizer}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0"])
  end
end
