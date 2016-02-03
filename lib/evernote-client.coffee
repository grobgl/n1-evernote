{Utils, React, FocusedContentStore} = require 'nylas-exports'
LocalStorage = require 'localStorage'
BrowserWindow = require('electron').remote.BrowserWindow
Evernote = require('evernote').Evernote
client = new Evernote.Client({ consumerKey: 'grobgl', consumerSecret: '259b25f020752d99', sandbox: true })
callbackUrl = 'http://evernote.callback'

class EvernoteClient

  _client = null


  get: (callback) ->
    if @_client
      return callback(null, @_client)

    oauthAccessToken = localStorage.getItem('evernote_token')
    if oauthAccessToken and oauthAccessToken != ''
      @_client = new Evernote.Client({token: oauthAccessToken});
      callback(null, @_client)
    else
      @_loginToEvernote (err, oauthAccessToken) =>
        if err
          @_client = null
          callback(err)
        else
          @_client = new Evernote.Client({token: oauthAccessToken})
          callback(null, @_client)


  _loginToEvernote: (callback) ->
    # callback with oauthAccessToken
    client.getRequestToken callbackUrl, (error, oauthToken, oauthTokenSecret, results) =>
      authorizeUrl = client.getAuthorizeUrl oauthToken
      authWindow = new BrowserWindow({
        width: 800,
        height: 600,
        show: false,
        resizable: false,
        'node-integration': false,
        'always-on-top': true,
        'skip-taskbar': true,
        frame: false,
        'standard-window': false
      })
      authWindow.loadUrl authorizeUrl
      authWindow.show()
      # authWindow.webContents.on 'will-navigate', (event, url) =>
      #   @_handleCallback url, oauthToken, oauthTokenSecret, authWindow, callback

      authWindow.webContents.on 'did-get-redirect-request', (event, oldUrl, newUrl) =>
        @_handleCallback newUrl, oauthToken, oauthTokenSecret, authWindow, callback

      authWindow.on 'close', () =>
        alert 'Could not log in (window closed)'
        callback(new Error('Window closed'))


  _handleCallback: (url, oauthToken, oauthTokenSecret, authWindow, callback) ->
    console.log '_handleCallback: ' + url
    # Only proceed if callback url is called by Evernote authenticator
    if url.substring(0, callbackUrl.length) == callbackUrl
      authWindow.destroy()

      # Read token from callback URL
      rawOauthVerifier = /oauth_verifier=([^&]*)/.exec(url) or null
      oauthVerifier = if rawOauthVerifier and rawOauthVerifier.length > 1 then rawOauthVerifier[1] else null

      if oauthVerifier
        client.getAccessToken oauthToken, oauthTokenSecret, oauthVerifier, (error, oauthAccessToken, oauthAccessTokenSecret, results) ->
          localStorage.setItem 'evernote_token', oauthAccessToken
          callback null, oauthAccessToken
      else
        callback(new Error('Could not get access token'))


module.exports = new EvernoteClient()
