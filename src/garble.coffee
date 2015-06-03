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
languages = require('./data/languages.json')

TRANSLATE_URI = 'https://translate.yandex.net/api/v1.5/tr.json/translate'
API_KEY = process.env.YANDEX_TRANSLATE_API_KEY
SOURCE_LANGUAGE = 'en'
DEFAULT_ITERATIONS = 4

getRandomLanguages = (count) ->
  # an array of all available language codes except SOURCE_LANGUAGE
  languageCodes = _.chain(languages).pluck('code').pull(SOURCE_LANGUAGE).value()

  # an array of randomly sorted languages
  randomLanguages = _.times count, () ->
    lang = _.sample(languageCodes)
    _.pull(languageCodes, lang)
    lang

  # add SOURCE_LANGUAGE as first and last items
  _.chain(randomLanguages).unshift(SOURCE_LANGUAGE).push(SOURCE_LANGUAGE).value()

getRequestString = (langFrom, langTo, text) ->
  opts =
    key: API_KEY
    lang: "#{langFrom}-#{langTo}"
    text: text
  return "#{TRANSLATE_URI}?#{querystring.stringify(opts)}"

parseResponse = (str) ->
  try
    return JSON.parse(str).text[0]
  catch e
    return "I'm sorry, I was unable to garble that text."

module.exports = (robot) ->

  robot.respond /garble (.*)/i, (msg) ->

    text = msg.match[1]?.trim()
    langs = getRandomLanguages(DEFAULT_ITERATIONS)

    request getRequestString(langs[0], langs[1], text), (error, response, body) ->
      request getRequestString(langs[1], langs[2], parseResponse(body)), (error, response, body) ->
        request getRequestString(langs[2], langs[3], parseResponse(body)), (error, response, body) ->
          request getRequestString(langs[3], langs[4], parseResponse(body)), (error, response, body) ->
            request getRequestString(langs[4], langs[5], parseResponse(body)), (error, response, body) ->
              msg.send parseResponse(body)
