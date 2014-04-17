Pod::Spec.new do |s|

  s.name         = "AFSQLManager"

  s.version      = "1.0"

  s.summary      = "SQL and SQLite manager for iOS."

  s.description  = "SQL and SQLite manage for iOS made easy."

  s.homepage     = "https://github.com/AlvaroFranco/AFSQLManager"

  s.license      = 'MIT'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Alvaro Franco" => "alvarofrancoayala@gmail.com" }

  s.platform     = :ios

  s.source       = { :git => "https://github.com/AlvaroFranco/AFSQLManager.git", :tag => 'v1.0' }

  s.source_files = 'AFSQLManager.h','AFSQLManager.m'

  s.requires_arc = true

end
