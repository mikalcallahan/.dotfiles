command: "LANG=fr_CA date +%a\" %d %b %Y\""
#command: "date +\"%A %d %B\""

refreshFrequency: 1000 # ms

render: (output) ->
  "#{output}"

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: transparent
  color: #e9e9e9
  display: flex
  font: .7em 'SF Mono'
  height: 1.4rem
  justify-content: center
  letter-spacing: 0.05em
  text-transform: lowercase
  width: 100%
  """
#color: #EFF1F3 #e9e9e9 #171717
