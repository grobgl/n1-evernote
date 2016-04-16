{ComponentRegistry, ExtensionRegistry} = require 'nylas-exports'
EvernoteMessageAction = require './ui/message-action'
# EvernoteComposer = require './ui/evernote-composer'

module.exports =
  # Activate is called when the package is loaded. If your package previously
  # saved state using `serialize` it is provided.
  #
  activate: (@state) ->
    ComponentRegistry.register EvernoteMessageAction,
      role: 'message:BodyHeader'
      # role: 'MessageActions'
      # role: 'thread:BulkAction'

    # You can add your own extensions to the N1 Composer view and the original
    # Composer by invoking `ExtensionRegistry.Composer.register` with a subclass of
    # `ComposerExtension`.
    # ExtensionRegistry.Composer.register EvernoteComposerExtension

  # Serialize is called when your package is about to be unmounted.
  # You can return a state object that will be passed back to your package
  # when it is re-activated.
  #
  serialize: ->

  # This **optional** method is called when the window is shutting down,
  # or when your package is being updated or disabled. If your package is
  # watching any files, holding external resources, providing commands or
  # subscribing to events, release them here.
  #
  deactivate: ->
    ComponentRegistry.unregister(EvernoteMessageAction)
