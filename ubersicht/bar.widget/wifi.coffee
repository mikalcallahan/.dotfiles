command: "echo $(sh bar.widget/scripts/wifi.sh)"

refreshFrequency: 2000 # ms

render: (output) ->
  "<span>#{output}</span>"

style: """
  -webkit-font-smoothing: antialiased
  align-items: center
  color: #e9e9e9
  display: flex
  font: .75em 'Inconsolata'
  height: 1.3rem
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
# background-color: #98bcbd #ffbebd #baddfc #dfbebd #98bb99 #ffde99 #dcabaa
# background-color: rgba(204,204,204,1) <----
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
