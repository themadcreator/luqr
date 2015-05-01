fs    = require 'fs-extra'
path  = require 'path'
_     = require 'underscore'
docco = require 'docco'
katex = require 'katex'

mustacheStyleSettings = {
  interpolate : /\{\{(.+?)\}\}/g
}

templateHelpers = {
  tex : (txt) -> katex.renderToString(txt)
}

render = (target) ->
  {source} = target

  # create docco config
  config = {
    marked    :
      smartypants : false
      sanitize    : false
    extension : 'coffee'
    languages :
      'coffee' : {
        literate       : true
        name           : 'coffeescript'
        symbol         : '#'
        commentMatcher : /^\s*#\s?/
        commentFilter  : /(^#![/]|^\s*#\{|^\s+#)/ # keep inline comments inline
      }
  }

  # parse using docco
  code     = fs.readFileSync(source, 'UTF-8')
  sections = docco.parse source, code, config

  # apply mustache-style template to section text
  for section in sections
    section.docsText = _.template(section.docsText, mustacheStyleSettings)(templateHelpers)

  # format with highlight-js through docco
  docco.format source, sections, config

  return _.template(fs.readFileSync(target.template, 'UTF-8'))(_.extend({sections}, target.templateOptions))

generate = (target) ->
  fs.writeFileSync path.join(target.output, 'index.html'), render(target)
  fs.copySync target.assets, path.join(target.output, '.')
  return

generate {
  output          : './gh-pages'
  template        : './site/template.jst'
  source          : './luqr.coffee.md'
  assets          : './site/assets'
  templateOptions :
    title    : 'LU, LDL, QR, and Solver'
    css      : [
      'css/docco.css'
      'css/katex.min.css'
      'css/normalize.css'
    ]
}
