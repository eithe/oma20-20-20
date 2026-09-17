import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

PanelWindow {
  id: root

  property bool active: false
  property var hostScreen: null
  property string fontFamily: Style.font.family
  signal dismissed()

  screen: root.hostScreen
  visible: root.active
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore

  WlrLayershell.namespace: "oma20-20-20-reminder"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: root.active
    ? WlrKeyboardFocus.Exclusive
    : WlrKeyboardFocus.None

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  Item {
    id: focusTarget
    anchors.fill: parent
    focus: root.active
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) root.dismissed()
      event.accepted = true
    }
  }

  BorderSurface {
    id: card
    z: 1
    anchors.centerIn: parent
    width: Style.space(440)
    height: Style.space(280)
    radius: Style.cornerRadius
    color: Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Style.space(2))

    Column {
      anchors.fill: parent
      anchors.margins: Style.space(28)
      spacing: Style.space(12)

      Text {
        text: "󰈈"
        color: Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.displayLarge
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        text: "20-20-20 break"
        color: Color.popups.text
        font.family: root.fontFamily
        font.pixelSize: Style.font.title
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      Text {
        text: "Look at something 20 feet away for 20 seconds."
        color: Color.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        wrapMode: Text.WordWrap
      }

      Item { width: 1; height: Style.space(8) }

      Text {
        text: "Press Escape to hide"
        color: Color.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }
  }

  onVisibleChanged: {
    if (visible) Qt.callLater(function() { focusTarget.forceActiveFocus() })
  }
}
