Pod::Spec.new do |s|

  s.name         = "ResultPromise"
  s.version      = "1.0.0"
  s.summary      = "Wrapping Result<Value, Error> in a Promise. Super-lightweight."

  s.description  = <<-DESC
                   Wrapping Result<Value, Error> in a Promise. Super-lightweight.
                   DESC

  s.homepage     = "https://github.com/itchingpixels/ResultPromise"

  s.license      = { :type => "MIT", :file => "LICENCE" }

  s.author             = { "Mark Szulyovszky" => "mark.szulyovszky@gmail.com" }
  s.social_media_url   = "http://twitter.com/itchingpixels"

  s.source       = { :git => "https://github.com/itchingpixels/ResultPromise.git", :tag => s.version }
  s.source_files = 'Framework/ResultPromise/*'
  s.exclude_files = "Example/*"
  s.ios.deployment_target = '8.0'
  s.dependency = "Result", "~> 1.0"

end
