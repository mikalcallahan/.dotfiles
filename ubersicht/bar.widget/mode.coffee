#command: "sh ./bar.widget/scripts/screens.sh"
command: "/usr/local/bin/chunkc tiling::query --desktop mode"

refreshFrequency: 1000 # ms


render: (output) ->
  """
    <link rel="stylesheet" type="text/css" href="./colors.css" />
    <div class='chunk-mode'>#{output}</div>
  """

style:
  """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: #ffde99
  color: #99736e
  display: flex
  font: .7em 'SF Mono'
  height: 2.85em
  justify-content: center
  left: 0
  text-align: center
  top: 0
  width: 5%
"""