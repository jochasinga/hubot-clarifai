# Description
#   A hubot script that learns from images and videos
#
# Configuration:
#   CLARIFAI_CLIENT_ID
#   CLARIFAI_CLIENT_SECRET
#
# Commands:
#   hubot <image or video url>
#
# Notes:
#   Register for a client id and secret with https://developer.clarifai.com
#
# Author:
#   Panisuan Chasinga <jo.chasinga@gmail.com>

module.exports = (robot) ->

	#clientId = "sB0wKtZj7KJZvI7_qffQUw6-am9aCFxhw7j3SkUs"
	#clientSecret = "_LXTYygWqRoC9ncEjWUDb2X6HcCZAqzDIyLhOL7k"
	clientId = CLARIFAI_CLIENT_ID
	clientSecret = CLARIFAI_CLIENT_SECRET
	grantType = "client_credentials"
	tokenUrl = "https://api.clarifai.com/v1/token/"
	tagUrl = "https://api.clarifai.com/v1/tag/"
	token = {}

	data = "grant_type=#{ grantType }&client_id=#{ clientId }&client_secret=#{ clientSecret }"

  getToken = ->
    new Promise((resolve, reject) ->
      robot.http(tokenUrl).post data, (err, res, body) ->
        if !err and res.statusCode == 200
          resolve res
        else
          reject err.message
        return
    )

  requestTags = (imgUrl) ->
    if token
      query = '?/url' + imgUrl
      new Promise((resolve, reject) ->
        robot.http(tagUrl + query).header('Authorization', token.token_type + ' ' + token.access_token).get (err, res, body) ->
          if !err and res.statusCode == 200
            resolve res
          else
            reject err.message
          return
      )

  # Main
  tokenPromise = getToken()
  tokenPromise.then ((data) ->
    # Token received
    token = JSON.parse(data)
    return
  ), (error) ->
    throw new Error(error.message)
    return

  robot.respond /https*:\/\/.{5,}[.]\b(jpg|jpeg|png|gif)\b$/, (msg) ->

    imgUrl = msg.match[0]

    tagPromise = requestTags(imgUrl)
    tagPromise.then ((data) ->
      tags = JSON.parse(data).results[0].result.tag.classes
      # TODO: make hubot reply with the tags in a more meaningful way
      # since tags are returned with many concepts
      tag = tags[Math.floor(Math.random() * items.length)]
      msg.send "Are you thinking of a #{ tag }?"
      return
    ), (error) ->
      # handle error the hubot way?
      msg.send "Sorry, I'm quite drowsy here. What was that?"
      return
