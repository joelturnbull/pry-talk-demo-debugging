# -*- encoding: utf-8 -*-
# stub: pry-clipboard 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "pry-clipboard"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Yuichi Tateno"]
  s.date = "2012-04-26"
  s.description = "pry clipboard utility"
  s.email = ["hotchpotch@gmail.com"]
  s.homepage = "https://github.com/hotchpotch/pry-clipboard"
  s.rubygems_version = "2.2.0"
  s.summary = "pry clipboard utility"

  s.installed_by_version = "2.2.0" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pry>, [">= 0"])
      s.add_runtime_dependency(%q<clipboard>, [">= 0"])
      s.add_development_dependency(%q<rr>, ["~> 1.0"])
      s.add_development_dependency(%q<bacon>, ["~> 1.1"])
      s.add_development_dependency(%q<open4>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<clipboard>, [">= 0"])
      s.add_dependency(%q<rr>, ["~> 1.0"])
      s.add_dependency(%q<bacon>, ["~> 1.1"])
      s.add_dependency(%q<open4>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<clipboard>, [">= 0"])
    s.add_dependency(%q<rr>, ["~> 1.0"])
    s.add_dependency(%q<bacon>, ["~> 1.1"])
    s.add_dependency(%q<open4>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
