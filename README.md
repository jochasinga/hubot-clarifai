# hubot-claribot

A hubot script that learns from images and videos

See [`src/claribot.coffee`](src/claribot.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-clarifai --save`

Then add **hubot-clarifai** to your `external-scripts.json`:

```json
[
  "hubot-clarifai"
]
```

## Sample Interaction

```
user1>> hubot http://example.com/cute-cat.jpg
hubot>> Are you thinking about a pet?
user2>> hubot https://domain.xyz/kate-moss.gif
hubot>> Feeling like a model?
```
