#prepare
mongoose = require('mongoose')

# Export Plugin
module.exports = (BasePlugin) ->
	class mongoPlugin extends BasePlugin
		name: 'mongo'

		config:
			hostname: 'mongodb://localhost/test'

		# Fetch list of Gigs
		# opts={} sets opts to default empty object if otherwise null
		# @ is this
		getGigsData: (opts={}, next) ->
			console.log "x2"
			config = @getConfig()
			docpad = @docpad

			mongoose.connect(config.hostname)
			db = mongoose.connection
			db.on 'error', (err) ->
				docpad.error(err)  # you may want to change this to `return next(err)`

			db.once 'open', -> 
				gigsSchema = mongoose.Schema {
					date: String,
					location: String
				}

				Gigs = mongoose.model('Gigs', gigsSchema)

				Gigs.find {}, (err, gigs) ->
					mongoose.connection.close()
					return next(err)  if err
					return next(null, gigs)

			# Chain
			@

		extendTemplateData: (opts,next) ->
			@getGigsData null, (err, gigs) ->
				console.log(gigs)
				return next(err) if err
				opts.templateData.gigs = gigs
				return next()

			# Chain
			@