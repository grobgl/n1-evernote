_ = require 'underscore'
{RetinaImg} = require 'nylas-component-kit'
{React} = require 'nylas-exports'
evernoteClient = require '../evernote-client'

class EvernoteToolbarButton extends React.Component
  @displayName: 'EvernoteToolbarButton'
  @propTypes:
    thread: React.PropTypes.object


  render: =>
    url = "nylas://n1-evernote/assets/evernote@2x.png"
    evernote = <button className="btn btn-toolbar toolbar-evernote"
                          onClick={@_onAddToEvernote}
                          title="Add to Evernote">
                    <RetinaImg
                      mode={RetinaImg.Mode.ContentIsMask}
                      url=url />
                  </button>
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


module.exports = EvernoteToolbarButton
