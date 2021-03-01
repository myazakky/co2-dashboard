import json, strformat, dom
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
    concentration*: int

proc update(room: Room) =
  ajaxGet(url = (fmt"https://discordapp.com/api/channels/{room.id}/messages").cstring,
          headers = headers,
          cont = proc (status: int, response: cstring) =
              if status != 200: return
              
              let data = ($response).parseJson
              room.concentration = data[0]["content"].str.parseInt)

var rooms = @[
  Room(name: node[0].name, concentration: 0, id: node[0].id),
  Room(name: node[1].name, concentration: 0, id: node[1].id),
  Room(name: node[2].name, concentration: 0, id: node[2].id),
  Room(name: node[3].name, concentration: 0, id: node[3].id)
]

func isGood(room: Room): bool =
  room.concentration < 1000

func toHtml(room: Room): VNode =
  buildHtml(tdiv(class = "roomCard")):
    p(class = "roomName"): text room.name
    p(class = "isGood"):
      if room.isGood: text "良好"
      else: text "不良"
    p(class = "ppm"): text $room.concentration & "ppm / 1000ppm"

func makeHeader(): VNode =
  buildHtml(tdiv(class = "header")):
    p(class = "title"): text "換気状況測定中"

proc createDom(): VNode =
  buildHtml(tdiv):
    makeHeader()
    tdiv:
      for room in rooms:
        room.toHtml

proc update(instance: KaraxInstance) =
  for room in rooms: room.update

var instance = setRenderer createDom

proc loop() = update(instance)
discard window.setInterval(loop, 10000)
