mongoose = require('mongoose')
updated = require('./updated')
config = require('../../config')['private']
require 'sugar'
l10n = (options)->
  _l10n = {}
  for language in config.languageSet
    _l10n[language] = options
  return _l10n

ProductSchemaDeclarative =
  code:
    type: String
  name: l10n String
  category:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Category'
  description: l10n String
  image:
    type: Boolean
    'default': false

tmp = Object.clone ProductSchemaDeclarative, true
tmp.code.unique = true

ProductSchema = new mongoose.Schema tmp

ProductSchema.virtual('imageUrl').get ->
  if @image
    return "#{config.s3.url}/product/#{@id}"
  else
    return "#{config.s3.url}/product/placeholder"

ProductSchema.plugin updated.plugin

ProductSchema.set 'toJSON', getters: true

module.exports = updated.preUpdate mongoose.model 'Product', ProductSchema
module.exports.declarative = ProductSchemaDeclarative
