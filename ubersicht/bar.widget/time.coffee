command: "date +%R"

refreshFrequency: 1000 # ms

render: (output) ->
  "#{output}"


style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: transparent
  color: #e9e9e9
  display: flex
  font: .75em 'Inconsolata'
  height: 1.3rem
  justify-content: center
  padding: 0 .75em 0 .5em
  right: 0
  text-align: center
  width: 5%
  """
# background-color: #dfbebd #98bcbd #98bb99
# color: #fcfdfd #ffde99 #ffbebd #84a89a #171717
