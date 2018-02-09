%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  app/models
  app/controllers
).each { |path| Spring.watch(path) }
