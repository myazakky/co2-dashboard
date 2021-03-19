import json, strformat, sequtils, dom
include karax/prelude
import karax/kajax

include config

let headers = [
  ("authorization".cstring, (fmt"Bot {token}").cstring),
  ("Content-Type".cstring, "application/json".cstring)
]

type
  Room = ref object
    name*: string
    id*: string
    plotUrl*: string
    concentration*: int

proc update(room: Room) =
  proc onRecieve(status: int, response: cstring) =
    if status != 200: return

    let datas = ($response).parseJson
    var
      getImage = false
      getConc = false
    for data in datas:
      if (not getImage) and data["content"].str == "":
        room.plotUrl = data["attachments"][0]["url"].str
        getImage = true
      if (not getConc) and data["content"].str != "":
        room.concentration = data["content"].str.parseInt
        getConc = true

  ajaxGet(url = (fmt"https://discordapp.com/api/channels/{room.id}/messages").cstring,
          headers = headers,
          cont = onRecieve)

var rooms = nodes.map(proc(node: RoomConf): Room =
  Room(name: node.name, id: node.id, concentration: 0, plotUrl: "./demoplot.png"),
)

func isGood(room: Room): bool =
  room.concentration < 1000

func toHtml(room: Room): VNode =
  buildHtml(tdiv(class = "roomCard")):
    p(class = "roomName"): text room.name
    if room.isGood:
      p(class = "isGood good"): text "いいね😆"
    else:
      p(class = "isGood bad"): text "換気しよ😑"
    p(class = "ppm"): text $room.concentration & "ppm"
    img(src = room.plotUrl, class="plot")

func makeHeader(): VNode =
  buildHtml(tdiv(class = "header")):
    p(class = "title"): text "換気状況測定中"

func makeDescriptionBox(): VNode =
  buildHtml(tdiv(class = "descriptionBox")):
    p(class = "description"): text "外気は大体500ppmです．"
    p(class = "description"): text "目安として1000ppmを超えると換気が十分でないと判断しています"
    p(class = "description"): text "ppm は ここでは濃度のことです．parts per millionの略で，百万分率のことです．"

proc createDom(): VNode =
  buildHtml(tdiv):
    makeHeader()
    tdiv(class = "roomCards"):
      for room in rooms:
        room.toHtml
    tdiv(class = "information"):
      tdiv(class = "members"):
        p(class = "pasokonClab"): text "パソコン部作成"
        tdiv(class = "sponsor"):
          p(class = "logoText"): text "協賛"
          img(
            class = "airnormLogo",
            src = "./airnorm-logo.png"
          )
      makeDescriptionBox()

proc update(instance: KaraxInstance) =
  for room in rooms: room.update

var instance = setRenderer createDom

proc loop() = update(instance)
discard window.setInterval(loop, 10000)
