gulp        = require 'gulp'
path        = require 'path'
config      = require '../config'
browserify  = require 'browserify'
babelify    = require 'babelify'
uglifyify   = require 'uglifyify'
stylify     = require 'stylify'
watchify    = require 'watchify'
source      = require 'vinyl-source-stream'
glob        = require 'glob'
watch       = require 'gulp-watch'
gutil       = require 'gulp-util'
browserSync = require 'browser-sync'

gulp.task 'watch', ->
  browserSync
    server:
      baseDir: config.documentRoot
    port: config.poot

  watch config.jade, -> gulp.start ['jade']
  watch config.documentRoot + '/**/*', -> browserSync.reload()

  files = glob.sync config.es6
  files.forEach (file) ->
    b = browserify
        entries: file
        extensions: ['.jsx', '.js']
        debug: true
        cache: {}
        packageCache: {}
        plugin: [watchify]
      .transform babelify
      .transform stylify

    bundle = (updatedFile) ->
      b.bundle()
        .on 'error', (err) -> gutil.log 'Browserify error:\n', err.message
        .pipe source path.basename(file, path.extname(file)) + '.js'
        .pipe gulp.dest 'dist/js'
      if updatedFile?
        updatedFile.map (filename) -> gutil.log 'File updated:', gutil.colors.yellow filename

    b.on 'update', bundle
    bundle()
