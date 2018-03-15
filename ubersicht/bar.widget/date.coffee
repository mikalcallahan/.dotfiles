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
  font: .75rem 'Inconsolata'
  height: 1.3rem
  justify-content: center
  letter-spacing: 0.04rem
  text-transform: lowercase
  width: 100%
  """
#color: #EFF1F3 #e9e9e9 #171717
