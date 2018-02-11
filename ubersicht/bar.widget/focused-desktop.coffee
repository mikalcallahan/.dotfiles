command: "/usr/local/bin/chunkc tiling::query --desktop id"

refreshFrequency: 1000 # ms

render: (output) ->
  """
  <div class='desktop-num'>#{output}</div>
  """

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: #dcabaa
  color: #333333
  display: flex
  font: .7em 'SF Mono'
  height: 1.4rem
  justify-content: center
  left: 0 
  text-align: center
  width: 6%
"""
# background-color: #ffbebd #98bb99 #98bcbd #ffde99
# color: #99736e #84a89a #fcfdfd #171717
# height: 20px
