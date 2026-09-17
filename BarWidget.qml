import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "tools/vision-break"

BarWidget {
  id: root
  moduleName: "io.github.eithe.oma20-20-20"

  property bool enabled: false
  property bool autoHide: true
  property bool rememberSettings: false
  property bool menuOpen: false
  property bool reminderVisible: false
  property bool settingsLoaded: false

  readonly property string settingsPath:
    Quickshell.env("HOME") + "/.local/state/omarchy/oma20-20-20.json"

  function open() {
    menuOpen = true
  }

  function close() {
    menuOpen = false
  }

  function toggleMenu() {
    menuOpen = !menuOpen
  }

  function toggleEnabled() {
    enabled = !enabled
    root.saveSettings()
  }

  function toggleAutoHide() {
    autoHide = !autoHide
    root.saveSettings()
  }

  function toggleRememberSettings() {
    rememberSettings = !rememberSettings
    root.saveSettings()
  }

  function loadSettings(raw: string) {
    if (settingsLoaded) return
    try {
      const parsed = raw ? JSON.parse(raw) : {}
      rememberSettings = parsed.rememberSettings === true
      if (rememberSettings) {
        enabled = parsed.enabled === true
        autoHide = parsed.autoHide !== false
      }
    } catch (error) {
      console.warn("20-20-20: settings parse failed", error)
    }
    settingsLoaded = true
  }

  function saveSettings() {
    if (!settingsLoaded) return
    settingsFile.setText(JSON.stringify({
      version: 1,
      enabled: enabled,
      autoHide: autoHide,
      rememberSettings: rememberSettings,
    }, null, 2) + "\n")
  }

  function dismissReminder() {
    reminderVisible = false
  }

  function toggleFromButton(buttonCode: int) {
    if (buttonCode === Qt.LeftButton) {
      toggleMenu()
    } else if (buttonCode === Qt.RightButton) {
      toggleEnabled()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  component ToggleRow: BorderSurface {
    id: toggleRow

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    signal activated()

    width: parent ? parent.width : 0
    height: Style.space(58)
    radius: Style.cornerRadius
    color: toggleMouse.containsMouse
      ? Style.hoverFillFor(Color.popups.text, Color.accent)
      : Style.normalFillFor(Color.popups.text, Color.accent)
    borderSpec: Border.controlSpec(
      toggleMouse.containsMouse ? "hover-cursor" : "normal",
      Color.popups.text,
      Color.accent)

    Row {
      anchors.fill: parent
      anchors.leftMargin: Style.space(12)
      anchors.rightMargin: Style.space(12)
      spacing: Style.space(12)

      Text {
        text: toggleRow.icon
        color: Color.accent
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.icon
        anchors.verticalCenter: parent.verticalCenter
      }

      Column {
        width: parent.width - Style.space(78)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
          text: toggleRow.title
          color: Color.popups.text
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        Text {
          text: toggleRow.subtitle
          color: Color.muted
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }
      }

      BorderSurface {
        width: Style.space(42)
        height: Style.space(24)
        radius: height / 2
        color: toggleRow.checked
          ? Style.selectedFillFor(Color.popups.text, Color.accent)
          : Style.normalFillFor(Color.popups.text, Color.accent)
        borderSpec: Border.controlSpec(
          toggleRow.checked ? "selected" : "normal",
          Color.popups.text,
          Color.accent)
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
          width: Style.space(16)
          height: width
          radius: width / 2
          anchors.verticalCenter: parent.verticalCenter
          x: toggleRow.checked ? parent.width - width - Style.space(4) : Style.space(4)
          color: toggleRow.checked ? Color.accent : Color.muted
          Behavior on x { NumberAnimation { duration: 120 } }
        }
      }
    }

    MouseArea {
      id: toggleMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: toggleRow.activated()
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰈈"
    tooltipText: root.enabled ? "20-20-20 reminders on" : "20-20-20 reminders off"
    active: root.enabled
    onPressed: function(buttonCode) { root.toggleFromButton(buttonCode) }
  }

  IpcHandler {
    target: root.moduleName

    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggleEnabled() }
  }

  PopupCard {
    id: menu
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.menuOpen
    contentWidth: menu.fittedContentWidth(Style.space(330))
    contentHeight: menu.fittedContentHeight(menuColumn.implicitHeight)

    Column {
      id: menuColumn
      anchors.fill: parent
      spacing: Style.space(8)

      Text {
        text: "20-20-20"
        color: Color.popups.text
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
      }

      Text {
        text: "Give your eyes a regular distance break"
        color: Color.muted
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.bodySmall
        width: parent.width
        wrapMode: Text.WordWrap
      }

      ToggleRow {
        icon: "󰈈"
        title: "Reminders"
        subtitle: root.enabled ? "On - break every 20 minutes" : "Off - reminders are paused"
        checked: root.enabled
        onActivated: root.toggleEnabled()
      }

      ToggleRow {
        icon: "󰖙"
        title: "Auto-hide"
        subtitle: root.autoHide ? "On - hides after 20 seconds" : "Off - press Escape to hide"
        checked: root.autoHide
        onActivated: root.toggleAutoHide()
      }

      ToggleRow {
        icon: "󰆓"
        title: "Remember settings"
        subtitle: root.rememberSettings
          ? "On - keeps choices after reboot"
          : "Off - starts with reminders off"
        checked: root.rememberSettings
        onActivated: root.toggleRememberSettings()
      }
    }
  }

  Timer {
    interval: 1 * 60 * 1000
    repeat: true
    running: root.enabled
    onTriggered: root.reminderVisible = true
  }

  Timer {
    id: autoHideTimer
    interval: 20 * 1000
    repeat: false
    running: root.reminderVisible && root.autoHide
    onTriggered: root.dismissReminder()
  }

  FileView {
    id: settingsFile
    path: root.settingsPath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadSettings(text())
    onLoadFailed: root.loadSettings("")
  }

  Process {
    id: settingsDirectory
    command: ["mkdir", "-p", root.settingsPath.substring(0, root.settingsPath.lastIndexOf("/"))]
    onExited: settingsFile.reload()
  }

  VisionBreak {
    active: root.reminderVisible
    hostScreen: button.QsWindow.window ? button.QsWindow.window.screen : null
    fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    onDismissed: root.dismissReminder()
  }

  Component.onCompleted: settingsDirectory.running = true
}
