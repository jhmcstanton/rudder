# frozen_string_literal: true

resource :rudder_git, :git do
  @source[:uri]    = 'https://github.com/jhmcstanton/rudder.git'
  @source[:branch] = 'master'
end
