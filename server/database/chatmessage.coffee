mongoose = require('mongoose')
updated = require('./updated')

ChatMessageSchema = new mongoose.Schema(
  name: String
  message: String
  userId:
    type: mongoose.Schema.Types.ObjectId
    ref: 'user'
  avatarUrl: String
,
  strict: true
)

module.exports = mongoose.model 'ChatMessage', ChatMessageSchema
