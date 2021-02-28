include karax/prelude

type
  Room = ref object
    name*: string
    concentration*: int

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

var rooms = @[
  Room(name: "大ホール", concentration: 600),
  Room(name: "中ホール", concentration: 600),
  Room(name: "展示ホール", concentration: 600),
  Room(name: "大ホール前", concentration: 9999)
]

proc createDom(): VNode =
  buildHtml(tdiv):
    makeHeader()
    tdiv:
      for room in rooms:
        room.toHtml

setRenderer createDom
