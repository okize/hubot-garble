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

LANGUAGES = require('./data/languages.json')
TRANSLATE_URI = 'https://translate.yandex.net/api/v1.5/tr.json/translate'
API_KEY = process.env.YANDEX_TRANSLATE_API_KEY
NATIVE_LANGUAGE = 'en'
DEFAULT_ITERATIONS = 5
SUPPRESS_TRANSLATION_PATH_LOG = process.env.HUBOT_GARBLE_TRANSLATION_PATH_LOG || false

getRandomLanguages = (count) ->
  # an array of all available language codes except NATIVE_LANGUAGE
  languageCodes = _.chain(LANGUAGES).pluck('code').pull(NATIVE_LANGUAGE).value()

  # an array of randomly sorted languages
  randomLanguages = _.times count, () ->
    lang = _.sample(languageCodes)
    _.pull(languageCodes, lang)
    lang

  # add NATIVE_LANGUAGE as first and last items
  _.chain(randomLanguages).unshift(NATIVE_LANGUAGE).push(NATIVE_LANGUAGE).value()

getRequestString = (langFrom, langTo, text) ->
  opts =
    key: API_KEY
    lang: "#{langFrom}-#{langTo}"
    text: text
  return "#{TRANSLATE_URI}?#{querystring.stringify(opts)}"

logTranslationPath = (languageCodes) ->
  # get full language name from language code
  languageNames = _.map languageCodes, (lang) ->
    _.result(_.find(LANGUAGES, 'code', lang), 'language')
  "translation path: #{languageNames.join(' -> ')}"

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
              request getRequestString(langs[5], langs[6], parseResponse(body)), (error, response, body) ->
                msg.send parseResponse(body)
                unless SUPPRESS_TRANSLATION_PATH_LOG == 'true'
                  msg.send logTranslationPath(langs)
