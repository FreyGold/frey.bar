import QtQuick
import QtQuick.Effects

Rectangle {
  id: root

  required property color baseColor
  required property color foreground
  property bool hovered: false
  property string styleName: "pill"
  property real surfaceOpacity: 0.70
  property real presence: 1
  property real borderStrength: 0.12
  property color edgeColor: foreground
  property real shadowStrength: 0
  property real cornerOverride: -1
  property real hoverStrength: 0.12
  property color accentColor: foreground
  readonly property int transitionDuration: 180

  color: hovered ? Qt.rgba(baseColor.r * (1 - hoverStrength) + accentColor.r * hoverStrength,
    baseColor.g * (1 - hoverStrength) + accentColor.g * hoverStrength,
    baseColor.b * (1 - hoverStrength) + accentColor.b * hoverStrength, 1) : baseColor
  radius: cornerOverride >= 0 ? Math.min(cornerOverride, Math.min(width, height) / 2) : styleName === "sharp"
    ? Math.min(2, Math.min(width, height) / 2)
    : styleName === "soft"
      ? Math.min(8, Math.min(width, height) / 2)
      : Math.min(width, height) / 2
  // Only this background frame fades; widget content remains crisp.
  opacity: Math.max(0, Math.min(1, surfaceOpacity * presence))
  border.width: borderStrength > 0 ? 1 : 0
  border.color: Qt.rgba(
    edgeColor.r,
    edgeColor.g,
    edgeColor.b,
    Math.min(1, borderStrength + (hovered ? hoverStrength : 0))
  )

  layer.enabled: shadowStrength > 0 && presence > 0
  layer.effect: MultiEffect {
    shadowEnabled: true
    shadowColor: "#000000"
    shadowOpacity: root.shadowStrength
    shadowBlur: 0.35
    shadowHorizontalOffset: 0
    shadowVerticalOffset: 1
  }

  Behavior on color {
    ColorAnimation { duration: root.transitionDuration; easing.type: Easing.InOutCubic }
  }

  Behavior on border.color {
    ColorAnimation { duration: root.transitionDuration; easing.type: Easing.InOutCubic }
  }

  Behavior on border.width {
    NumberAnimation { duration: root.transitionDuration; easing.type: Easing.InOutCubic }
  }

  Behavior on radius {
    NumberAnimation { duration: root.transitionDuration; easing.type: Easing.InOutCubic }
  }
}
