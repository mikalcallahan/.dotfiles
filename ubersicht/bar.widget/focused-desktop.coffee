command: "/usr/local/bin/chunkc tiling::query --desktop id"

refreshFrequency: 1000 # ms

render: (output) ->
  """
  <div class='desktop-num'>#{output}</div>
  """

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: #ffde99
  color: #171717
  display: flex
  font: .7em 'SF Mono'
  height: 30px
  justify-content: center
  left: 0
  text-align: center
  top: 0
  width: 6%
"""
# background-color: #ffbebd #98bb99 #98bcbd #ffde99
# color: #99736e #84a89a #fcfdfd
