[![NPM version](http://img.shields.io/npm/v/hubot-garble.svg?style=flat)](https://www.npmjs.org/package/hubot-garble)
[![Build Status](http://img.shields.io/travis/okize/hubot-garble.svg?style=flat)](https://travis-ci.org/okize/hubot-garble)
[![Dependency Status](http://img.shields.io/david/okize/hubot-garble.svg?style=flat)](https://david-dm.org/okize/hubot-garble)
[![Downloads](http://img.shields.io/npm/dm/hubot-garble.svg?style=flat)](https://www.npmjs.org/package/hubot-garble)

# Hubot: Garble

Hubot script that garbles your text

## Usage

In a chatroom, type:

    hubot garble [1-9] <text>

Hubot will return *garbled* text by translating the original text N number of times, where N is an optional argument between 1 and 9 (default is 5).

## Configuration

ENV variable | Description
--- | ---
``YANDEX_TRANSLATE_API_KEY`` | string; a [Yandex API key](https://tech.yandex.com/keys/get/?service=trnsl) (*required*)
``HUBOT_GARBLE_LOCAL_LANGUAGE`` | string; language code for chatroom language (optional; default is 'en')
``HUBOT_GARBLE_TRANSLATION_PATH_LOG`` | boolean; display the translation path that text followed during garbling process (optional; default is true)

## Installation

Add the package `hubot-garble` as a dependency in your Hubot `package.json` file.

```javascript
"dependencies": {
  "hubot-garble": "^1.0.0"
}
```

Run the following command to make sure the module is installed.

```bash
npm install hubot-garble
```

To enable the script, add the `hubot-garble` entry to the `external-scripts.json` file (_you may need to create this file_).

```javascript
["hubot-garble"]
```
