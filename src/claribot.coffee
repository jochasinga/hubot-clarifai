# Description
#   A hubot script that learns from images and videos
#
# Configuration:
#   HUBOT_CLARIFAI_CLIENT_ID
#   HUBOT_CLARIFAI_CLIENT_SECRET
#
# Commands:
#   hubot <image or video url>
#
# Notes:
#   Register for a client id and secret with https://developer.clarifai.com
#
# Author:
#   Panisuan Chasinga <jo.chasinga@gmail.com>

clientId = process.env.HUBOT_CLARIFAI_CLIENT_ID
clientSecret = process.env.HUBOT_CLARIFAI_CLIENT_SECRET

module.exports = (robot) ->

  grantType = "client_credentials"
  tokenUrl = "https://api.clarifai.com/v1/token/"
  tagUrl = "https://api.clarifai.com/v1/tag/"
  token = {}
  grant = "grant_type=#{ grantType }&client_id=#{ clientId }&client_secret=#{ clientSecret }"

  responses = [
    "Are you thinking of a #{ tag }?"
    "Feeling like a #{ tag }?"
    "I love #{ tag } too. You know, on my better days."
    "Perhaps you could tell me more about #{ tag } over a coffee."
    "Ever heard of a robot #{ tag }?"
    "Go get your #{ tag } now! You're annoying me."
  ]

  getToken = ->
    new Promise((resolve, reject) ->
      robot.http(tokenUrl).post grant, (err, res, body) ->
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
      #msg.send "Are you thinking of a #{ tag }?"
      msg.send responses[Math.floor(Math.random() * items.length)]
      return
    ), (error) ->
      # handle error the hubot way?
      msg.send "Sorry, I'm quite drowsy here. What was that?"
      return
