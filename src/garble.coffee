# Description:
#   Garbles your text
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot garble <text> - garbles your text
#
# Notes
#   None
#
# Author:
#   Morgan Wigmanich <okize123@gmail.com> (https://github.com/okize)

module.exports = (robot) ->

  robot.respond /garble/i, (msg) ->
    msg.send 'Garbled textttt'
