_ = require 'underscore'
{React} = require 'nylas-exports'
EvernoteClient = require '../evernote-client'

class EvernoteQuickAction extends React.Component
  @displayName: 'EvernoteQuickActions'
  @propTypes:
    thread: React.PropTypes.object


  render: =>
    evernote = <div key="evernote"
                 title="Add to Evernote"
                 style={{ order: 90 }}
                 className={'btn action action-evernote'}
                 onClick={@_onAddToEvernote}></div>
    return evernote


  _onAddToEvernote: (event) =>
    # Don't trigger the thread row click
    event.stopPropagation()

    # Get evernote client instance
    EvernoteClient.get (err, client) =>
      if err
        alert err.message
      else
        noteStore = client.getNoteStore()
        noteStore.listNotebooks (err, notebooks) ->
          _.each notebooks, (notebook) ->
            console.log(notebook.name)


module.exports = EvernoteQuickAction
