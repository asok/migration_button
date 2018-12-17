MigrationButton::Engine.routes.draw do
  get  "/"              => "runner#index"
  post "/migrate"       => "runner#migrate"

  post "/up/:version"   => "runner#up"
  post "/down/:version" => "runner#down"
end
