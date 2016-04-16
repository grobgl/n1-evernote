_ = require 'underscore'
{React, Actions} = require 'nylas-exports'
{Menu, RetinaImg, Popover} = require 'nylas-component-kit'
BrowserWindow = require('electron').remote.BrowserWindow
EvernoteClient = require '../evernote-client'
htmlToEnml = require('htmltoenml')

class EvernoteMessageAction extends React.Component
  @displayName: 'evernote-message-action'
  @propTypes:
    thread: React.PropTypes.object

  constructor: (@props) ->
    super(@props)

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
    # Get evernote client instance
    EvernoteClient.get().then (client) =>
        console.log 'CONVERTING ...'
        htmlToEnml.fromString @props.message.body, {ignoreFiles: true}, (err, enml, resources) =>
          if err
            console.log 'Convert error!'
          else
            console.log enml
            client.makeNote @props.message.subject, enml, null, (err) =>
              if err
                console.log err
              else
                console.log 'SUCCESS'
      , (err) =>
        console.log err

module.exports = EvernoteMessageAction
