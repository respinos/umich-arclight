desc 'JavaScript linting'
task lint: :environment do
  sh "yarn lint"
end
