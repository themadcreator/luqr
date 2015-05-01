gulp       = require 'gulp'
ghPages    = require 'gulp-gh-pages'
bump       = require 'gulp-bump'
rename     = require 'gulp-rename'
coffee     = require 'gulp-coffee'
mocha      = require 'gulp-mocha'
gutil      = require 'gulp-util'
git        = require 'gulp-git'
uglify     = require 'gulp-uglify'
header     = require 'gulp-header'
map        = require 'vinyl-map'

{exec}     = require 'child_process'
{literate} = require './site/literator'

GET_VERSION = -> JSON.parse(require('fs').readFileSync('./version.json', 'UTF-8'))

### TEST ###

gulp.task 'test', ->
  gulp.src('test/*-test.coffee', {read : false}).pipe(mocha())


### BUILD ###

gulp.task 'build', ->
  {version} = GET_VERSION()
  options   =
    version   : version
    year      : new Date().getFullYear()
    timestamp : new Date().valueOf().toString(16).toUpperCase()

  gulp.src('./luqr.coffee.md')
    .pipe(coffee({bare : true, literate : true}).on('error', gutil.log))
    .pipe(uglify({mangle : true}))
    .pipe(header('/* LU, LDL, and QR Matrix Decomposer and Solver. v<%= version%> (c) <%= year%> Bill Dwyer. MIT License. Build <%= timestamp%> */\n', options))
    .pipe(rename('ldl.min.js'))
    .pipe(gulp.dest('.'))


### RENDER ####

gulp.task 'render-gh-pages', ->
  options =
    template        : './site/template.jst'
    templateOptions :
      title : 'LU, LDL, QR, and Solver'
      css   : [
        'css/docco.css'
        'css/katex.min.css'
        'css/normalize.css'
      ]

  literator = map (code, filename) ->
    literate(code.toString('UTF-8'), filename, options)

  gulp.src('./luqr.coffee.md')
    .pipe(literator)
    .pipe(rename('index.html'))
    .pipe(gulp.dest('./gh-pages'))

gulp.task 'copy-gh-pages-assets', ->
  gulp.src('./site/assets/**/*').pipe(gulp.dest('./gh-pages'))


### PUBLISH ###

gulp.task 'bump-version', ->
  gulp.src(['./version.json'])
    .pipe(bump({type : 'minor'}))
    .pipe(gulp.dest('./'))

gulp.task 'set-versions', ->
  options = GET_VERSION()
  gulp.src(['./package.json', './bower.json'])
    .pipe(bump(options))
    .pipe(gulp.dest('./'))

gulp.task 'git-commit', ->
  {version} = GET_VERSION()
  return gulp.src('.').pipe(git.commit("Bumped version for release #{version}", {args: '-a'}))

gulp.task 'git-tag', (cb) ->
  {version} = GET_VERSION()
  git.tag version, "Created tag for release #{version}", (cb)

gulp.task 'git-push', (cb) ->
  git.push('origin', 'master', {args : '--tags'}, cb)

gulp.task 'publish-gh-pages', [
  'render-gh-pages'
  'copy-gh-pages-assets'
], ->
  gulp.src('./gh-pages/**/*').pipe(ghPages())

gulp.task 'publish-npm', (cb) ->
  exec 'npm publish ./', cb

gulp.task 'publish-bower', (cb) ->
  exec 'bower register lurq git@github.com:themadcreator/luqr.git', cb

gulp.task 'publish', [
  'test'
  'set-versions'
  'build'
  'git-commit'
  'git-tag'
  'git-push'
  'publish-npm'
  'publish-bower'
  'publish-gh-pages'
]


### DEV TASKS ###

DEV_TASKS = [
  'test'
  'serve-gh-pages'
]

gulp.task 'serve-gh-pages', ['render-gh-pages', 'copy-gh-pages-assets'], (cb) ->
  exec 'npm run serve',

gulp.task 'watch', DEV_TASKS, ->
  gulp.watch(['./luqr.coffee.md', 'test/**', 'site/**'], DEV_TASKS)