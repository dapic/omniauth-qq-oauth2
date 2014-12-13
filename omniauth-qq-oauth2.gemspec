# coding: utf-8
require File.expand_path('../lib/omniauth-qq-oauth2/version', __FILE__)
Gem::Specification.new do |spec|
    spec.name          = "omniauth-qq-oauth2"
    spec.version       = OmniAuth::Qq::VERSION
    spec.authors       = ["Cireate"]
    spec.email         = ["jacky8ts@gmail.com"]
    spec.description   = %q{OmniAuth for QQ}
    spec.summary       = %q{OmniAuth for QQ}
    spec.homepage      = "https://github.com/yeetim/omniauth-qq-oauth2"

    spec.files         = `git ls-files`.split("\n")
    spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    spec.require_paths = ["lib"]

    spec.add_development_dependency 'omniauth', '~> 1.0'
    spec.add_development_dependency 'omniauth-oauth', '~> 1.0'
    spec.add_development_dependency 'omniauth-oauth2', '~> 1.0'
    spec.add_development_dependency 'multi_json'
end
