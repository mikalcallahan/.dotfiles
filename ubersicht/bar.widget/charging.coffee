command: "pmset -g batt | grep 'AC Power' -o;"

refreshFrequency: 1000 # ms

render: (output) ->
  """
  <div class="charging"
    <span></span>
    <span class="icon fa"></span>
  </div>
  """

update: (output, el) ->
  $(".charging span:first-child", el)
  elIcon = $(".charging span.icon", el)
  elIcon.removeClass().addClass("icon fa #{@icon(output)}")

icon: (output) =>
  return if output is "AC Power\n"
    "fa-bolt"
  else
    ""

style: """
  -webkit-font-smoothing: antialiased
  color: #d8de9c
  display: flex
  font: 14px
  top: .95%
  right: 9.8%
"""
