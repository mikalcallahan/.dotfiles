command: "/usr/local/bin/chunkc tiling::query --window tag"

refreshFrequency: 1000 # ms

render: (output) ->
  "<span>#{output}</span>"

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: transparent
  color: #e9e9e9
  display: flex
  font: .7em 'SF Mono'
  height: 20px
  justify-content: center
  left: 7em
  padding: 0 1.5em
  text-align: center
  text-transform: lowercase
  width: 20%
  span
    display: block
    overflow: hidden
    text-overflow: ellipsis
    white-space: nowrap
"""
# background-color: #98bcbd #616161 #719672 #98bb99
# color: #fcfdfd #84a89a #99736e #e9e9e9 #171717
# whitespace: nowrap
