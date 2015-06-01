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
#   Forgive this terrible first pass, I was in a rush
#
# Author:
#   Morgan Wigmanich <okize123@gmail.com> (https://github.com/okize)

querystring = require('querystring')
_ = require('lodash')
request = require('request')
Progger = require('progger')
languages = require('./data/languages.json')

TRANSLATE_URI = 'https://translate.yandex.net/api/v1.5/tr.json/translate'
API_KEY = process.env.YANDEX_TRANSLATE_API_KEY
GARBLE_COUNT = 4

getRandomLanguages = (count) ->
  # get all language codes except english
  languageCodes = _.chain(languages).pluck('code').pull('en').value()
  randomLanguages = []
  while count > 0
    count--
    lang = _.sample(languageCodes)
    randomLanguages.push lang
    _.pull(languageCodes, lang)
  return randomLanguages

getRequestString = (langFrom, langTo, text) ->
  opts =
    key: API_KEY
    lang: "#{langFrom}-#{langTo}"
    text: text
  return "#{TRANSLATE_URI}?#{querystring.stringify(opts)}"

parseRes = (str) ->
  JSON.parse(str).text[0]

module.exports = (robot) ->

  robot.respond /garble (.*)/i, (msg) ->

    text = msg.match[1]?.trim()
    langs = getRandomLanguages(GARBLE_COUNT)

    request getRequestString('en', langs[0], text), (error, response, body) ->
      request getRequestString(langs[0], langs[1], parseRes(body)), (error, response, body) ->
        request getRequestString(langs[1], langs[2], parseRes(body)), (error, response, body) ->
          request getRequestString(langs[2], langs[3], parseRes(body)), (error, response, body) ->
            request getRequestString(langs[3], 'en', parseRes(body)), (error, response, body) ->
              msg.send parseRes(body)
