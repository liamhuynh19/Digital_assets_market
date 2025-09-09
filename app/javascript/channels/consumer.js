// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

// Explicitly specify the WebSocket URL with protocol detection
// const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
// const wsHost = window.location.hostname
// const wsPort = window.location.port ? `:${window.location.port}` : ''

export default createConsumer(`${wsProtocol}//${wsHost}${wsPort}/cable`)
