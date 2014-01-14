mongoose = require('mongoose')
updated = require('./updated')

CategorySchema = new mongoose.Schema(
  code:
    type: String
    unique: true
  name: String
,
  strict: true
)
CategorySchema.plugin updated.plugin

module.exports = updated.preUpdate mongoose.model 'Category', CategorySchema
