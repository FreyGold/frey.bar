pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons
import qs.Ui

KeyboardPanel {
    id: popup

    property var savedAppearance: null
    property string activeTab: "simple"
    property string advancedCategory: "background"
    property string selectedSavedPreset: ""
    onOpenChanged: if (open && bar)
        savedAppearance = bar.appearanceSnapshot()
    centerOnBar: true
    focusTarget: content
    contentWidth: popup.fittedContentWidth(Style.space(390))
    contentHeight: popup.fittedContentHeight(content.implicitHeight)

    Component.onCompleted: if (bar)
        bar.registerStyleEditor(popup)
    Component.onDestruction: if (bar)
        bar.unregisterStyleEditor(popup)

    Column {
        id: content
        Keys.onEscapePressed: popup.close()

        anchors.fill: parent
        spacing: Style.space(12)

        Row {
            width: parent.width
            spacing: Style.space(8)

            Column {
                width: parent.width - closeButton.width - parent.spacing
                spacing: Style.space(2)

                Text {
                    text: "Bar appearance"
                    color: Color.foreground
                    font.family: popup.bar.fontFamily
                    font.pixelSize: Style.font.subtitle
                    font.bold: true
                }

                Text {
                    width: parent.width
                    text: popup.activeTab === "simple" ? "Style and opacity" : popup.activeTab === "blur" ? "Blur strength" : "Colors and spacing"
                    color: Color.foreground
                    font.family: popup.bar.fontFamily
                    font.pixelSize: Style.font.caption
                }
            }

            Button {
                id: closeButton
                iconText: "×"
                tooltipText: "Close"
                foreground: Color.foreground
                horizontalPadding: Style.space(8)
                verticalPadding: Style.space(4)
                onClicked: popup.close()
            }
        }

        ButtonGroup {
            options: [
                {
                    value: "simple",
                    label: "Simple"
                },
                {
                    value: "advanced",
                    label: "Advanced"
                }, {value: "blur", label: "Blur"}
            ]
            value: popup.activeTab
            foreground: Color.foreground
            accent: popup.bar.accentColor
            background: Color.background
            fontFamily: popup.bar.fontFamily
            focusable: true
            onChanged: function (value) {
                popup.activeTab = value;
            }
        }

        BorderSurface {
            width: parent.width
            height: Style.space(54)
            color: Style.normalFillFor(Color.foreground, Color.accent)
            borderSpec: Border.controlSpec("normal", Color.foreground, Color.accent)
            radius: Style.cornerRadius

            Rectangle {
                anchors.centerIn: parent
                width: Style.space(54 + 76 + 42) + popup.bar.pillGap * 2
                height: Style.space(25)
                color: popup.bar.background
                opacity: popup.bar.surfaceOpacity * (1 - popup.bar.styledSurfaceProgress)
            }

            Row {
                anchors.centerIn: parent
                spacing: popup.bar.pillGap

                Repeater {
                    model: [54, 76, 42]

                    delegate: Item {
                        required property int modelData

                        width: Style.space(modelData)
                        height: Style.space(25)

                        PillFrame {
                            anchors.fill: parent
                            baseColor: popup.bar.background
                            foreground: popup.bar.barForeground
                            styleName: popup.bar.surfaceStyle
                            surfaceOpacity: popup.bar.surfaceOpacity
                            presence: popup.bar.styledSurfaceProgress
                            borderStrength: popup.bar.borderStrength
                            edgeColor: popup.bar.customBorderColor || popup.bar.barForeground
                            shadowStrength: popup.bar.shadowStrength
                            cornerOverride: popup.bar.cornerRadius
                            hoverStrength: popup.bar.hoverStrength
                            accentColor: popup.bar.accentColor
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.52
                            height: Math.max(2, Style.space(2))
                            radius: height / 2
                            color: popup.bar.barForeground
                            opacity: 0.72
                        }
                    }
                }
            }
        }

        Column {
            visible: popup.activeTab === "simple"
            width: parent.width
            spacing: Style.space(7)
            Text {
                text: "PRESETS"
                color: Color.foreground
                font.pixelSize: Style.font.caption
                font.bold: true
            }
            ButtonGroup {
                options: [
                    {
                        value: "Minimal",
                        label: "Minimal"
                    },
                    {
                        value: "Glass",
                        label: "Glass"
                    },
                    {
                        value: "Solid",
                        label: "Solid"
                    }
                ]
                foreground: Color.foreground
                background: Color.background
                accent: popup.bar.accentColor
                onChanged: function (value) {
                    popup.bar.applyAppearancePreset(value);
                }
            }
            Row {
                width: parent.width
                spacing: Style.space(8)
                TextField {
                    id: presetName
                    width: parent.width - savePresetButton.width - parent.spacing
                    placeholderText: "Name your current style"
                    maximumLength: 32
                }
                Button {
                    id: savePresetButton
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Save"
                    foreground: Color.foreground
                    enabled: presetName.text.trim().length > 0 && !popup.bar.builtInPresets[presetName.text.trim()]
                    onClicked: {
                        popup.bar.saveAppearancePreset(presetName.text);
                        presetName.text = "";
                    }
                }
            }
            Text {
                visible: Object.keys(popup.bar.savedPresets).length > 0
                text: "Saved presets"
                color: Color.foreground
                font.pixelSize: Style.font.caption
            }
            Row {
                width: parent.width
                visible: Object.keys(popup.bar.savedPresets).length > 0
                spacing: Style.space(8)
                Dropdown {
                    width: parent.width - deletePresetButton.width - parent.spacing
                    label: "Saved presets"
                    showLabel: false
                    options: Object.keys(popup.bar.savedPresets).sort()
                    value: popup.selectedSavedPreset
                    accent: popup.bar.accentColor
                    onChanged: function (value) {
                        popup.selectedSavedPreset = value;
                        popup.bar.applyAppearancePreset(value);
                    }
                }
                Button {
                    id: deletePresetButton
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Delete"
                    foreground: Color.foreground
                    enabled: popup.selectedSavedPreset !== ""
                    onClicked: {
                        popup.bar.removeAppearancePreset(popup.selectedSavedPreset);
                        popup.selectedSavedPreset = "";
                    }
                }
            }
        }

        Column {
            visible: popup.activeTab === "simple"
            width: parent.width
            spacing: Style.space(7)

            Text {
                text: "STYLE"
                color: Color.foreground
                font.family: popup.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
            }

            ButtonGroup {
                options: [
                    {
                        value: "original",
                        label: "Original"
                    },
                    {
                        value: "pill",
                        label: "Pill"
                    },
                    {
                        value: "soft",
                        label: "Soft"
                    },
                    {
                        value: "sharp",
                        label: "Sharp"
                    }
                ]
                value: popup.bar.surfaceStyle
                foreground: Color.foreground
                background: popup.bar.background
                accent: popup.bar.accentColor
                fontFamily: popup.bar.fontFamily
                focusable: true
                onChanged: function (value) {
                    popup.bar.setSurfaceStyle(value);
                }
            }
        }

        Column {
            visible: popup.activeTab === "simple"
            width: parent.width
            spacing: Style.space(7)

            Row {
                width: parent.width

                Text {
                    text: "OPACITY"
                    color: Color.foreground
                    font.family: popup.bar.fontFamily
                    font.pixelSize: Style.font.caption
                    font.bold: true
                }

                Text {
                    width: parent.width - x
                    text: Math.round(opacitySlider.dragging ? opacitySlider.liveValue : popup.bar.surfaceOpacity * 100) + "%"
                    color: Color.foreground
                    font.family: popup.bar.fontFamily
                    font.pixelSize: Style.font.body
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                }
            }

            AppearanceSlider {
                id: opacitySlider

                width: parent.width
                minimum: 0
                maximum: 100
                step: 1
                integer: true
                value: popup.bar.surfaceOpacity * 100
                onMoved: function (value) {
                    popup.bar.previewSurfaceOpacity(value / 100);
                }
                onReleased: function (value) {
                    popup.bar.setSurfaceOpacity(value / 100);
                }
            }
        }

        Toggle {
            visible: popup.activeTab === "simple"
            width: parent.width
            label: "Appearance button"
            description: "Show the gear on the bar; right-click also opens this editor"
            checked: popup.bar.showAppearanceButton
            accent: popup.bar.accentColor
            onClicked: popup.bar.setAppearance({
                showAppearanceButton: !popup.bar.showAppearanceButton
            })
        }

        Dropdown {
            visible: popup.activeTab === "advanced"
            width: parent.width
            showLabel: false
            options: [
                {
                    value: "background",
                    label: "Background"
                },
                {
                    value: "text",
                    label: "Text & icons"
                },
                {
                    value: "border",
                    label: "Border"
                },
                {
                    value: "layout",
                    label: "Spacing & shape"
                },
                {
                    value: "effects",
                    label: "Effects"
                }
            ]
            value: popup.advancedCategory
            accent: popup.bar.accentColor
            onChanged: function (value) {
                popup.advancedCategory = value;
                advancedScroll.contentY = 0;
            }
        }

        Flickable {
            id: advancedScroll
            visible: popup.activeTab === "advanced" || popup.activeTab === "blur"
            width: parent.width
            height: Math.min(advancedContent.implicitHeight, Style.space(440), Math.max(180, popup.availableCardHeight - Style.space(340)))
            contentWidth: width
            contentHeight: advancedContent.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: advancedContent
                width: advancedScroll.width
                spacing: Style.space(12)

                Text {
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "text"
                    text: "TEXT & ICON COLOR"
                    color: Color.foreground
                    font.family: popup.bar.fontFamily
                    font.pixelSize: Style.font.caption
                    font.bold: true
                }

                ButtonGroup {
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "text"
                    options: [
                        {
                            value: "auto",
                            label: "Auto"
                        },
                        {
                            value: "theme",
                            label: "Theme"
                        },
                        {
                            value: "white",
                            label: "White"
                        },
                        {
                            value: "black",
                            label: "Black"
                        },
                        {
                            value: "custom",
                            label: "Custom"
                        }
                    ]
                    value: popup.bar.textColorMode
                    foreground: Color.foreground
                    background: Color.background
                    onChanged: function (value) {
                        popup.bar.setAppearance({
                            textColorMode: value
                        });
                    }
                }

                TextField {
                    width: parent.width
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "text" && popup.bar.textColorMode === "custom"
                    text: popup.bar.customTextColor
                    placeholderText: "Text color: #ffffff"
                    validator: RegularExpressionValidator {
                        regularExpression: /#[0-9a-fA-F]{6}/
                    }
                    onTextEdited: if (acceptableInput)
                        popup.bar.setAppearance({
                            textColor: text
                        })
                }

                Text {
                    width: parent.width
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "text" && popup.bar.textColorMode === "auto"
                    text: "Auto balances wallpaper brightness with background opacity."
                    color: Color.foreground
                    font.pixelSize: Style.font.caption
                    wrapMode: Text.WordWrap
                }

                Text {
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "background"
                    text: "BACKGROUND COLOR"
                    color: Color.foreground
                    font.pixelSize: Style.font.caption
                    font.bold: true
                }

                Row {
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "background"
                    width: parent.width
                    spacing: Style.space(8)
                    TextField {
                        width: parent.width - themeButton.width - parent.spacing
                        text: popup.bar.customBackgroundColor
                        placeholderText: "Theme default / #202020"
                        validator: RegularExpressionValidator {
                            regularExpression: /#[0-9a-fA-F]{6}/
                        }
                        onTextEdited: if (acceptableInput)
                            popup.bar.setAppearance({
                                backgroundColor: text
                            })
                    }
                    Button {
                        id: themeButton
                        text: "Theme"
                        foreground: Color.foreground
                        onClicked: popup.bar.setAppearance({
                            backgroundColor: ""
                        })
                    }
                }

                Repeater {
                    model: [
                        {
                            key: "widgetGap",
                            category: "layout",
                            label: "Widget gap",
                            min: 0,
                            max: 16,
                            factor: 1
                        },
                        {
                            key: "widgetPadding",
                            category: "layout",
                            label: "Inner padding",
                            min: 0,
                            max: 16,
                            factor: 1
                        },
                        {
                            key: "cornerRadius",
                            category: "layout",
                            label: "Corner radius",
                            min: -1,
                            max: 16,
                            factor: 1
                        },
                        {
                            key: "borderStrength",
                            category: "border",
                            label: "Border opacity",
                            min: 0,
                            max: 100,
                            factor: 100
                        },
                        {
                            key: "shadowStrength",
                            category: "effects",
                            label: "Shadow strength",
                            min: 0,
                            max: 60,
                            factor: 100
                        },
                        {
                            key: "hoverStrength",
                            category: "effects",
                            label: "Hover highlight",
                            min: 0,
                            max: 40,
                            factor: 100
                        }
                    ]
                    delegate: Column {
                        required property var modelData
                        visible: popup.activeTab === "advanced" && modelData.category === popup.advancedCategory
                        width: parent.width
                        spacing: Style.space(4)
                        Text {
                            text: modelData.label + ": " + (modelData.key === "cornerRadius" && popup.bar.cornerRadius < 0 ? "Follow style" : Math.round(popup.bar[modelData.key] * modelData.factor) + (modelData.factor === 100 ? "%" : " px"))
                            color: Color.foreground
                            font.pixelSize: Style.font.caption
                        }
                        AppearanceSlider {
                            width: parent.width
                            minimum: parent.modelData.min
                            maximum: parent.modelData.max
                            step: 1
                            integer: true
                            value: popup.bar[parent.modelData.key] * parent.modelData.factor
                            onMoved: function (value) {
                                var values = {};
                                values[parent.modelData.key] = value / parent.modelData.factor;
                                popup.bar.setAppearance(values, false);
                            }
                            onReleased: function (value) {
                                var values = {};
                                values[parent.modelData.key] = value / parent.modelData.factor;
                                popup.bar.setAppearance(values);
                            }
                        }
                    }
                }

                Toggle {
                    width: parent.width
                    visible: popup.activeTab === "blur"
                    label: "Background blur"
                    description: "Frosted surfaces; visible below 100% opacity"
                    checked: popup.bar.blurEnabled
                    accent: popup.bar.accentColor
                    onClicked: popup.bar.setAppearance({
                        blurEnabled: !popup.bar.blurEnabled
                    })
                }

                Column {
                    visible: popup.activeTab === "blur"
                    width: parent.width
                    spacing: Style.space(8)
                    Text {
                        text: "Strength: " + popup.bar.blurStrength
                        color: Color.foreground
                        font.pixelSize: Style.font.body
                    }
                    AppearanceSlider {
                        width: parent.width
                        minimum: 1
                        maximum: 20
                        step: 1
                        integer: true
                        value: popup.bar.blurStrength
                        onMoved: function(value) { popup.bar.setAppearance({blurStrength: value}, false) }
                        onReleased: function(value) { popup.bar.setAppearance({blurStrength: value}) }
                    }
                    Text {
                        width: parent.width
                        text: "Hyprland shares blur strength across windows and panels. Higher values soften more detail. Bar blur is visible below 100% opacity."
                        color: Color.foreground
                        font.pixelSize: Style.font.caption
                        wrapMode: Text.WordWrap
                    }
                }

                Repeater {
                    model: [
                        {
                            key: "borderColor",
                            category: "border",
                            propertyKey: "customBorderColor",
                            label: "Border color"
                        },
                        {
                            key: "accentColor",
                            category: "text",
                            propertyKey: "customAccentColor",
                            label: "Accent color"
                        }
                    ]
                    delegate: Column {
                        required property var modelData
                        visible: popup.activeTab === "advanced" && modelData.category === popup.advancedCategory
                        width: parent.width
                        spacing: Style.space(4)
                        Text {
                            text: modelData.label
                            color: Color.foreground
                            font.pixelSize: Style.font.caption
                        }
                        Row {
                            width: parent.width
                            spacing: Style.space(8)
                            TextField {
                                width: parent.width - clearColorButton.width - parent.spacing
                                text: popup.bar[parent.parent.modelData.propertyKey]
                                placeholderText: "Theme default / #RRGGBB"
                                validator: RegularExpressionValidator {
                                    regularExpression: /#[0-9a-fA-F]{6}/
                                }
                                onTextEdited: if (acceptableInput) {
                                    var values = {};
                                    values[parent.parent.modelData.key] = text;
                                    popup.bar.setAppearance(values);
                                }
                            }
                            Button {
                                id: clearColorButton
                                text: "Theme"
                                foreground: Color.foreground
                                onClicked: {
                                    var values = {};
                                    values[parent.parent.modelData.key] = "";
                                    popup.bar.setAppearance(values);
                                }
                            }
                        }
                    }
                }
                Text {
                    width: parent.width
                    visible: popup.activeTab === "advanced" && popup.advancedCategory === "layout"
                    text: "Choosing a Simple style restores its default corner radius."
                    color: Color.foreground
                    font.pixelSize: Style.font.caption
                    wrapMode: Text.WordWrap
                }
            }
        }

        Button {
            width: parent.width
            text: "Undo changes"
            foreground: Color.foreground
            bordered: true
            onClicked: if (popup.savedAppearance)
                popup.bar.setAppearance(popup.savedAppearance)
        }

        Button {
            width: parent.width
            text: "Reset to original"
            tooltipText: "Restore the stock Omarchy bar appearance"
            bordered: true
            focusable: true
            foreground: Color.foreground
            background: popup.bar.background
            accent: popup.bar.accentColor
            onClicked: popup.bar.resetSurfaceAppearance()
        }

        Text {
            width: parent.width
            text: "Tip: right-click anywhere on the bar to open this panel again."
            color: Color.foreground
            font.family: popup.bar.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
        }
    }
}
