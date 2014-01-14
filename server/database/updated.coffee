# @todo complete Dependency Injection
ObjectId = require('mongoose').Schema.Types.ObjectId

# Last modified Mongoose plugin
exports.plugin = (schema, options) ->
  schema.add updatedAt: Number
  schema.pre "save", (next) ->
    @updatedAt = Date.now()
    next()
  schema.add updatedBy:
    type: ObjectId
    ref: 'User'

  schema.path("updated").index options.index  if options and options.index

exports.preUpdate = (Collection)->
  update = Collection.update
  Collection.update = (query, data, options..., cb)->
    options = options[0]
    data.updatedAt = @updatedAt = Date.now()
    update.call Collection, query, data, options, cb
  Collection

  findOneAndUpdate = Collection.findOneAndUpdate
  Collection.findOneAndUpdate = (query, data, options..., cb)->
    options = options[0]
    data.updatedAt = @updatedAt = Date.now()
    findOneAndUpdate.call Collection, query, data, options, cb
  Collection
