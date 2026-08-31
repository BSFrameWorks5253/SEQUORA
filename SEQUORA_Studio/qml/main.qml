// ============================================================
// qml/main.qml
// SEQUORA — Creative Studio Suite (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Window
import "components"
import "pages"

ApplicationWindow {
    id: root
    width: 1400
    height: 900
    minimumWidth: 1040
    minimumHeight: 680
    visible: true
    title: "SEQUORA Studio — Creative Production Suite"
    color: appTheme.bg

    // ── Active Page Navigation State ──────────────────────────────────────────
    property string activePage: "overview"

    // ── Design & Color System (Desktop-native Light & Dark) ───────────────────
    property string currentThemeMode: (typeof photoEngine !== "undefined" && photoEngine && photoEngine.config && photoEngine.config["theme"]) ? photoEngine.config["theme"] : "dark"

    QtObject {
        id: appTheme
        property string name: root.currentThemeMode
        property bool   isDark:          name === "dark"

        // Surface Colors (Apple Pro / Linear Studio Dark & Crisp Studio Light)
        property color  bg:              isDark ? "#0D0D11" : "#F8F9FA"
        property color  sidebar:         isDark ? "#121217" : "#FFFFFF"
        property color  surface:         isDark ? "#17171E" : "#FFFFFF"
        property color  surfaceElevated: isDark ? "#1D1D26" : "#F1F3F5"
        property color  surface2:        isDark ? "#22222E" : "#F4F5F7"
        property color  surfaceGlass:    isDark ? Qt.rgba(0.08, 0.08, 0.11, 0.88) : Qt.rgba(1.0, 1.0, 1.0, 0.92)
        property color  surfaceGlassElevated: isDark ? Qt.rgba(0.12, 0.12, 0.16, 0.92) : Qt.rgba(0.95, 0.96, 0.98, 0.94)

        // Borders
        property color  border_:         isDark ? "#262633" : "#E2E8F0"
        property color  borderSubtle:    isDark ? "#1B1B25" : "#EDF0F2"
        property color  borderHover:     isDark ? "#3A3A4D" : "#CBD5E1"
        property color  borderGlass:     isDark ? Qt.rgba(0.35, 0.35, 0.45, 0.6) : Qt.rgba(0.85, 0.88, 0.92, 0.8)

        // Typography
        property color  textPrimary:     isDark ? "#F8F8FC" : "#18181B"
        property color  textSecondary:   isDark ? "#A0A0B2" : "#52525B"
        property color  textMuted:       isDark ? "#6E6E82" : "#71717A"

        // Primary Accent (Vibrant Studio Violet)
        property color  accent:          isDark ? "#8B6CE6" : "#7C5CBF"
        property color  accentHover:     isDark ? "#9E80F5" : "#6D48C5"
        property color  accentSoft:      isDark ? "#261E3B" : "#F3EEFC"

        // Semantic Status & Camera Angles
        property color  success:         isDark ? "#34D399" : "#059669"
        property color  successSoft:     isDark ? "#0D2A20" : "#ECFDF5"
        property color  warning:         isDark ? "#FBBF24" : "#D97706"
        property color  warningSoft:     isDark ? "#2E220C" : "#FFFBEB"
        property color  danger:          isDark ? "#F87171" : "#DC2626"
        property color  dangerSoft:      isDark ? "#2E1414" : "#FEF2F2"
        property color  info:            isDark ? "#38BDF8" : "#0284C7"
        property color  infoSoft:        isDark ? "#082F49" : "#F0F9FF"

        // Dedicated Camera Angle & Pipeline Tag Tokens
        property color  camA:            isDark ? "#818CF8" : "#4F46E5"
        property color  camASoft:        isDark ? Qt.rgba(0.51, 0.55, 0.97, 0.16) : Qt.rgba(0.31, 0.27, 0.9, 0.12)
        property color  camB:            isDark ? "#F472B6" : "#DB2777"
        property color  camBSoft:        isDark ? Qt.rgba(0.96, 0.45, 0.71, 0.16) : Qt.rgba(0.86, 0.15, 0.47, 0.12)
        property color  matchedTag:      isDark ? "#34D399" : "#059669"
        property color  dryRunTag:       isDark ? "#38BDF8" : "#0284C7"
    }

    // ── Main Desktop Layout ───────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Sidebar Navigation (232px) ────────────────────────────────────────
        Sidebar {
            id: sidebar
            theme: appTheme
            activePage: root.activePage
            onNavigate: (pageKey) => root.activePage = pageKey
            onOpenSettings: settingsModal.open()
        }

        // ── Content Shell ─────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Top Bar
            TopToolbar {
                id: topToolbar
                theme: appTheme
                activePage: root.activePage
                zoomFactor: root.zoomLevel
                onOpenSettings: settingsModal.open()
                onOpenCommandPalette: cmdPalette.open()
                onToggleTheme: {
                    var next = root.currentThemeMode === "dark" ? "light" : "dark"
                    root.currentThemeMode = next
                    if (typeof photoEngine !== "undefined" && photoEngine) {
                        var cfg = Object.assign({}, photoEngine.config || {})
                        cfg["theme"] = next
                        photoEngine.saveConfig(cfg)
                    }
                }
                onZoomIn: root.zoomIn()
                onZoomOut: root.zoomOut()
                onResetZoom: root.resetZoom()
            }

            // Page Switcher Area with Smooth Eased Cross-Fade & Micro-Slide
            Item {
                id: pageContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                property int targetIndex: {
                    if (root.activePage === "overview")           return 0
                    if (root.activePage === "photoMatcher")       return 1
                    if (root.activePage === "videoTransfer")      return 2
                    if (root.activePage === "thumbnailSeparator" || root.activePage === "pvSeparator") return 3
                    if (root.activePage === "remainingCollector") return 4
                    if (root.activePage === "googleDriveMain" || root.activePage === "googleDriveThumbs") return 5
                    if (root.activePage === "activity")           return 6
                    if (root.activePage === "excelMerger")        return 7
                    return 0
                }

                OverviewPage {
                    id: pageOverview
                    anchors.fill: parent
                    theme: appTheme
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 0 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 0 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    onNavigate: (p) => root.activePage = p
                }

                PhotoMatcherPage {
                    id: pagePhoto
                    anchors.fill: parent
                    theme: appTheme
                    engine: typeof photoEngine !== "undefined" ? photoEngine : null
                    dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 1 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 1 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                VideoTransferPage {
                    id: pageVideo
                    anchors.fill: parent
                    theme: appTheme
                    engine: typeof videoEngine !== "undefined" ? videoEngine : null
                    dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 2 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 2 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                PVSeparatorPage {
                    id: pagePV
                    anchors.fill: parent
                    theme: appTheme
                    engine: typeof pvSeparatorEngine !== "undefined" ? pvSeparatorEngine : (typeof thumbEngine !== "undefined" ? thumbEngine : null)
                    dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 3 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 3 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                RemainingCollectorPage {
                    id: pageRemaining
                    anchors.fill: parent
                    theme: appTheme
                    engine: typeof remainingEngine !== "undefined" ? remainingEngine : null
                    dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 4 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 4 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                GoogleDrivePage {
                    id: pageDrive
                    anchors.fill: parent
                    theme: appTheme
                    engine: typeof driveEngine !== "undefined" ? driveEngine : null
                    activeDriveTab: root.activePage === "googleDriveThumbs" ? "thumbnails" : "main"
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 5 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 5 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                ActivityPage {
                    id: pageActivity
                    anchors.fill: parent
                    theme: appTheme
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 6 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 6 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                ExcelMergerPage {
                    id: pageExcelMerger
                    anchors.fill: parent
                    theme: appTheme
                    engine: typeof excelMergerEngine !== "undefined" ? excelMergerEngine : null
                    dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                    visible: opacity > 0
                    opacity: pageContainer.targetIndex === 7 ? 1.0 : 0.0
                    y: pageContainer.targetIndex === 7 ? 0 : 6
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }
        }
    }

    // ── Command Palette (Ctrl + K) ────────────────────────────────────────────
    CommandPalette {
        id: cmdPalette
        theme: appTheme
        onNavigate: (pageKey) => root.activePage = pageKey
        onActionTriggered: (action) => {
            if (action === "settings") settingsModal.open()
        }
    }

    // ── Settings Modal ────────────────────────────────────────────────────────
    SettingsModal {
        id: settingsModal
        engine: typeof photoEngine !== "undefined" ? photoEngine : null
        theme:  appTheme
        onChangeTheme: (t) => {
            root.currentThemeMode = t
            if (typeof photoEngine !== "undefined" && photoEngine) {
                var cfg = Object.assign({}, photoEngine.config || {})
                cfg["theme"] = t
                photoEngine.saveConfig(cfg)
            }
        }
    }

    // ── Global Toast Notification ─────────────────────────────────────────────
    ToastNotification { id: globalToast; theme: appTheme }

    // ── Chrome-Grade Zoom System ──────────────────────────────────────────────
    property real zoomLevel: 1.0

    function zoomIn() {
        var next = Math.min(1.5, Math.round((root.zoomLevel + 0.1) * 10) / 10)
        root.zoomLevel = next
        root.contentItem.scale = next
        zoomHud.show()
    }

    function zoomOut() {
        var next = Math.max(0.7, Math.round((root.zoomLevel - 0.1) * 10) / 10)
        root.zoomLevel = next
        root.contentItem.scale = next
        zoomHud.show()
    }

    function resetZoom() {
        root.zoomLevel = 1.0
        root.contentItem.scale = 1.0
        zoomHud.show()
    }

    WheelHandler {
        acceptedModifiers: Qt.ControlModifier
        onWheel: (event) => {
            if (event.angleDelta.y > 0) root.zoomIn()
            else if (event.angleDelta.y < 0) root.zoomOut()
        }
    }

    Shortcut { sequence: "Ctrl+="; onActivated: root.zoomIn() }
    Shortcut { sequence: "Ctrl++"; onActivated: root.zoomIn() }
    Shortcut { sequence: "Ctrl+-"; onActivated: root.zoomOut() }
    Shortcut { sequence: "Ctrl+_"; onActivated: root.zoomOut() }
    Shortcut { sequence: "Ctrl+0"; onActivated: root.resetZoom() }
    Shortcut { sequence: "Ctrl+K"; onActivated: cmdPalette.open() }

    // ── Floating Zoom HUD Indicator ───────────────────────────────────────────
    Rectangle {
        id: zoomHud
        z: 9999
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 20
        height: 32
        width: zoomHudRow.implicitWidth + 20
        radius: 6
        color: appTheme.surface
        border.color: appTheme.border_
        border.width: 1
        opacity: 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 160 } }

        Timer {
            id: hudTimer; interval: 1600; repeat: false
            onTriggered: zoomHud.opacity = 0
        }

        function show() {
            zoomHud.opacity = 0.98
            hudTimer.restart()
        }

        RowLayout {
            id: zoomHudRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "🔍 " + Math.round(root.zoomLevel * 100) + "%"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.family: "Consolas, monospace"
                color: appTheme.textPrimary
            }

            Rectangle {
                visible: Math.round(root.zoomLevel * 100) !== 100
                height: 20
                width: resetLbl.implicitWidth + 10
                radius: 4
                color: appTheme.accentSoft

                Text {
                    id: resetLbl
                    anchors.centerIn: parent
                    text: "Reset"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: appTheme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.resetZoom()
                }
            }
        }
    }

    // ── Global Hot Reload Shortcuts (F5 and Ctrl+R) ───────────────────────────
    Shortcut {
        sequence: "F5"
        onActivated: if (typeof appReloader !== "undefined" && appReloader) appReloader.restartApp()
    }
    Shortcut {
        sequence: "Ctrl+R"
        onActivated: if (typeof appReloader !== "undefined" && appReloader) appReloader.restartApp()
    }
}
