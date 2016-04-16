{Utils, React, FocusedContentStore} = require 'nylas-exports'
LocalStorage = require 'localStorage'
BrowserWindow = require('electron').remote.BrowserWindow
Evernote = require('evernote').Evernote
client = new Evernote.Client({ consumerKey: 'grobgl', consumerSecret: '259b25f020752d99', sandbox: true })
callbackUrl = 'http://evernote.callback'

class EvernoteClient

  instance = null
  get: () ->
    return new Promise (resolve, reject) ->
      if instance
        resolve instance
      else
        instance = new _EvernoteClient
        instance.init (err) ->
          if err
            reject err
          else
            resolve instance


  class _EvernoteClient
    init: ->
      oauthAccessToken = localStorage.getItem('evernote_token')
      if oauthAccessToken and oauthAccessToken != ''
        @_client = new Evernote.Client({token: oauthAccessToken});
      else
        @_loginToEvernote (err, oauthAccessToken) =>
          if err
            @_client = null
          else
            @_client = new Evernote.Client({token: oauthAccessToken})

    makeNote: (noteTitle, noteContent, parentNotebook, callback) =>
      if !@_client
        callback new Error('Client not defined')

      ourNote = new Evernote.Note
      ourNote.title = noteTitle
      ourNote.content = noteContent

      # parentNotebook is optional; if omitted, default notebook is used
      if parentNotebook and parentNotebook.guid
        ourNote.notebookGuid = parentNotebook.guid

      noteStore = @_client.getNoteStore()
      noteStore.createNote ourNote, callback

    _loginToEvernote: (callback) ->
      # callback with oauthAccessToken
      client.getRequestToken callbackUrl, (error, oauthToken, oauthTokenSecret, results) =>
        authorizeUrl = client.getAuthorizeUrl oauthToken
        authWindow = new BrowserWindow
          width: 800,
          height: 600,
          show: false,
          resizable: false,
          'node-integration': false,
          'always-on-top': true,
          'skip-taskbar': true,
          frame: false,
          'standard-window': false
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

  # # Returns Evernote client instance. Logs in user if user is not logged in yet.
  # get: (callback) ->
  #   if @_client
  #     return callback(null, @_client)
  #
  #   oauthAccessToken = localStorage.getItem('evernote_token')
  #   if oauthAccessToken and oauthAccessToken != ''
  #     @_client = new Evernote.Client({token: oauthAccessToken});
  #     callback(null, @_client)
  #   else
  #     @_loginToEvernote (err, oauthAccessToken) =>
  #       if err
  #         @_client = null
  #         callback(err)
  #       else
  #         @_client = new Evernote.Client({token: oauthAccessToken})
  #         callback(null, @_client)
  #
  # makeNote: (noteTitle, noteBody, parentNotebook, callback) ->
  #   if !@_client
  #     callback new Error('Client not defined')
  #
  #   nBody = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>' +
  #           '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">' +
  #           noteBody +
  #           '<en-note></en-note>'
  #   ourNote = new Evernote.Note
  #   ourNote.title = noteTitle
  #   ourNote.content = nBody
  #
  #   # parentNotebook is optional; if omitted, default notebook is used
  #   if parentNotebook and parentNotebook.guid
  #     ourNote.notebookGuid = parentNotebook.guid
  #
  #   noteStore = client.getNoteStore()
  #   noteStore.createNote ourNote, callback
  #
  # _loginToEvernote: (callback) ->
  #   # callback with oauthAccessToken
  #   client.getRequestToken callbackUrl, (error, oauthToken, oauthTokenSecret, results) =>
  #     authorizeUrl = client.getAuthorizeUrl oauthToken
  #     authWindow = new BrowserWindow
  #       width: 800,
  #       height: 600,
  #       show: false,
  #       resizable: false,
  #       'node-integration': false,
  #       'always-on-top': true,
  #       'skip-taskbar': true,
  #       frame: false,
  #       'standard-window': false
  #     authWindow.loadUrl authorizeUrl
  #     authWindow.show()
  #     # authWindow.webContents.on 'will-navigate', (event, url) =>
  #     #   @_handleCallback url, oauthToken, oauthTokenSecret, authWindow, callback
  #
  #     authWindow.webContents.on 'did-get-redirect-request', (event, oldUrl, newUrl) =>
  #       @_handleCallback newUrl, oauthToken, oauthTokenSecret, authWindow, callback
  #
  #     authWindow.on 'close', () =>
  #       alert 'Could not log in (window closed)'
  #       callback(new Error('Window closed'))
  #
  #
  # _handleCallback: (url, oauthToken, oauthTokenSecret, authWindow, callback) ->
  #   console.log '_handleCallback: ' + url
  #   # Only proceed if callback url is called by Evernote authenticator
  #   if url.substring(0, callbackUrl.length) == callbackUrl
  #     authWindow.destroy()
  #
  #     # Read token from callback URL
  #     rawOauthVerifier = /oauth_verifier=([^&]*)/.exec(url) or null
  #     oauthVerifier = if rawOauthVerifier and rawOauthVerifier.length > 1 then rawOauthVerifier[1] else null
  #
  #     if oauthVerifier
  #       client.getAccessToken oauthToken, oauthTokenSecret, oauthVerifier, (error, oauthAccessToken, oauthAccessTokenSecret, results) ->
  #         localStorage.setItem 'evernote_token', oauthAccessToken
  #         callback null, oauthAccessToken
  #     else
  #       callback(new Error('Could not get access token'))


module.exports = new EvernoteClient()
