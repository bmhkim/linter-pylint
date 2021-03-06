{exec} = require 'child_process'
linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"

class LinterPylint extends Linter
  @syntax: 'source.python' # fits all *.py-files

  linterName: 'pylint'

  regex: '^(?<line>\\d+),(?<col>\\d+),\
          ((?<error>fatal|error)|(?<warning>warning|convention|refactor)),\
          (?<msg_id>\\w\\d+):(?<message>.*)$'
  regexFlags: 'm'

  constructor: (@editor) ->
    super @editor

    # sets @cwd to the dirname of the current file
    # if we're in a project, use that path instead
    # TODO: Fix this up so it works with multiple directories
    paths = atom.project.getPaths()
    @cwd = paths[0] || @cwd

    # Set to observe config options
    @executableListener = atom.config.observe 'linter-pylint.executable', => @updateCommand()
    @rcFileListener = atom.config.observe 'linter-pylint.rcFile', => @updateCommand()

  destroy: ->
    super
    @executableListener.dispose()
    @rcFileListener.dispose()

  # Sets the command based on config options
  updateCommand: ->
    cmd = [atom.config.get 'linter-pylint.executable']

    showCodes = atom.config.get 'linter-pylint.showCodes'
    showReadableCodes = atom.config.get 'linter-pylint.showReadableCodes'

    msgCodes = ""
    if showCodes or showReadableCodes
      msgCodes = '('
      if showCodes
        msgCodes += '{msg_id}'
        if showReadableCodes
          msgCodes += ';'
      if showReadableCodes
        msgCodes += '{symbol}'
      msgCodes += ') '
    cmd.push "--msg-template='{line},{column},{category},{msg_id}:" + msgCodes + "{msg}'"
    cmd.push '--reports=n'
    cmd.push '--output-format=text'

    rcFile = atom.config.get 'linter-pylint.rcFile'
    if rcFile
      cmd.push "--rcfile=#{rcFile}"

    @cmd = cmd


module.exports = LinterPylint
