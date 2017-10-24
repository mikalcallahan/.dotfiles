command: "date +%A\" %d %b %y\""
#command: "date +\"%a %d %b\""

refreshFrequency: 1000 # ms

render: (output) ->
  "#{output}"

style: """
	-webkit-font-smoothing: antialiased
	align-items: center
	color: #171717
	display: flex
	font: .7em 'SF Mono'
	height: 30px
	justify-content: center
	letter-spacing: 0.05em
	top: 0
	width: 100%
  """
#color: #EFF1F3 #e9e9e9
