# frozen_string_literal: true

resource :sample_resource, :git do
  source[:uri] = 'some-uri'
end

job :sample_job do
  plan << { get: :sample_resource }
end
