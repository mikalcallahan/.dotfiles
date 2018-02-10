command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 1000 # ms

render: (output) ->
  "bat <span>#{output}</span>"

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: transparent
  color: #e9e9e9
  display: flex
  font: .7em 'SF Mono'
  height: 20px
  justify-content: center
  right: 7.5em
  padding: 0 .65em 0 1em
  text-align: center
  text-transform: lowercase
  top: 0
  width: 6%
"""
#background-color: #ffde99 #ffbebd #dfbebd
#color: #171717
