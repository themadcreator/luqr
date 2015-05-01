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

literate = (code, source, options) ->
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
  sections = docco.parse source, code, config

  # apply mustache-style template to section text
  for section in sections
    section.docsText = _.template(section.docsText, mustacheStyleSettings)(templateHelpers)

  # format with highlight-js through docco
  docco.format source, sections, config

  return _.template(fs.readFileSync(options.template, 'UTF-8'))(_.extend({sections}, options.templateOptions))

module.exports = {literate}
