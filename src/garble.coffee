# Description:
#   Garbles your text
#
# Dependencies:
#   None
#
# Configuration:
#   YANDEX_TRANSLATE_API_KEY              string; a Yandex API key (required)
#   HUBOT_GARBLE_LOCAL_LANGUAGE           string; language code for chatroom language (optional; default is 'en')
#   HUBOT_GARBLE_TRANSLATION_PATH_LOG     boolean; display the translation path that text followed during garbling process (optional; default is true)
#
# Commands:
#   hubot garble [1 - 9] <text> - garbles your text by [least - most] amount (default 5)
#
# Notes
#   None
#
# Author:
#   Morgan Wigmanich <okize123@gmail.com> (https://github.com/okize)

querystring = require('querystring')
_ = require('lodash')
request = require('request')
LANGUAGES = require('./data/languages.json')
TRANSLATE_URI = 'https://translate.yandex.net/api/v1.5/tr.json/translate'
API_KEY = process.env.YANDEX_TRANSLATE_API_KEY
LOCAL_LANGUAGE = process.env.HUBOT_GARBLE_LOCAL_LANGUAGE || 'en'
SHOW_TRANSLATION_PATH = process.env.HUBOT_GARBLE_TRANSLATION_PATH_LOG || true
DEFAULT_GARBLE_AMOUNT = 5

# get full language name from a language code
getLanguageName = (languageCode) ->
  _.result(_.find(LANGUAGES, 'code', languageCode), 'language')

# an array of all available language codes except LOCAL_LANGUAGE
getLanguageCodes = () ->
  _.chain(LANGUAGES).pluck('code').pull(LOCAL_LANGUAGE).value()

# an array of random languages; length determined by garbling amount
getRandomLanguages = (languageCodes, garbleAmount) ->
  _.times garbleAmount, () ->
    lang = _.sample(languageCodes)
    _.pull(languageCodes, lang)
    lang

# an array of languages to translate text through
# wraps LOCAL_LANGUAGE around random assortment of languages
getTranslationPath = (garbleAmount) ->
  _.chain(getRandomLanguages(getLanguageCodes(), garbleAmount))
    .unshift(LOCAL_LANGUAGE)
    .push(LOCAL_LANGUAGE)
    .value()

# a string that indicates what "translation path" the text was passed through
getTranslationPathLog = (languageCodes) ->
  languageNames = _.map languageCodes, (code) -> getLanguageName(code)
  "translation path: #{languageNames.join(' → ')}"

# a URI that satisfies the Yandex API requirements
getRequestURI = (langFrom, langTo, text) ->
  opts =
    key: API_KEY
    lang: "#{langFrom}-#{langTo}"
    text: text
  return "#{TRANSLATE_URI}?#{querystring.stringify(opts)}"

# a string of translated text
parseResponse = (str) ->
  try
    return JSON.parse(str).text[0]
  catch e
    return "I'm sorry, I was unable to garble that text."

module.exports = (robot) ->

  robot.respond /garble (.*)/i, (msg) ->

    text = msg.match[1]?.trim()
    regex = /^\d+\s*/
    garbleAmount = regex.exec(text)

    if garbleAmount?
      amount = parseInt(garbleAmount[0], 10)
      garbleAmount = if (1 <= amount <= 9) then amount else DEFAULT_GARBLE_AMOUNT
      text = text.replace(regex, '')
    else
      garbleAmount = DEFAULT_GARBLE_AMOUNT

    langs = getTranslationPath(garbleAmount)

    if text?.length

      request getRequestURI(langs[0], langs[1], text), (error, response, body) ->
        request getRequestURI(langs[1], langs[2], parseResponse(body)), (error, response, body) ->
          request getRequestURI(langs[2], langs[3], parseResponse(body)), (error, response, body) ->
            request getRequestURI(langs[3], langs[4], parseResponse(body)), (error, response, body) ->
              request getRequestURI(langs[4], langs[5], parseResponse(body)), (error, response, body) ->
                request getRequestURI(langs[5], langs[6], parseResponse(body)), (error, response, body) ->
                  msg.send parseResponse(body)
                  unless SHOW_TRANSLATION_PATH == 'false'
                    msg.send getTranslationPathLog(langs)
