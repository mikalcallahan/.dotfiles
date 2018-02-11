command: "echo $(sh bar.widget/scripts/wifi.sh)"

refreshFrequency: 2000 # ms

render: (output) ->
  "<span>#{output}</span>"

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  background-color: #dcabaa
  color: #333333
  display: flex
  font: .7em 'SF Mono'
  height: 1.395rem
  justify-content: center
  padding: 0 1em
  right: 16em
  text-align: center
  text-transform: lowercase
  width: 10.5%
  span
    display: block
    overflow: hidden
    text-overflow: ellipsis
    word-spacing: -0.70em;
    white-space: nowrap
"""
# background-color: #98bcbd #ffbebd #baddfc #dfbebd #98bb99 #ffde99
# color: #171717
 
getWifiStatus: (status, netName, netIP) ->
###
  if status == "Wi-Fi"
    return "<span class='wifi '>&nbsp&nbsp&nbsp</span><span class='white'>#{netName}&nbsp</span>"
  if status == 'USB 10/100/1000 LAN' or status == 'Apple USB Ethernet Adapter'
    return "<span class='wifi '>&nbsp&nbsp&nbsp</span><span class='white'>#{netIP}</span>"
  else
    return "<span class='grey wifi'>&nbsp&nbsp&nbsp</span><span class='white'>--&nbsp&nbsp&nbsp</span>"
###
icon: (output) =>
  #return "fa-wifi"
