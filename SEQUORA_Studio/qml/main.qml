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

    // ── Persistent Theme & Zoom Level State ───────────────────────────────────
    property string currentThemeMode: (typeof photoEngine !== "undefined" && photoEngine && photoEngine.config && photoEngine.config["theme"]) ? photoEngine.config["theme"] : "dark"
    property real   zoomLevel: (typeof photoEngine !== "undefined" && photoEngine && photoEngine.config && photoEngine.config["zoomLevel"]) ? photoEngine.config["zoomLevel"] : 1.0

    // ── Luxury Warm Beige & Obsidian Dark Design System Matrix ────────────────
    QtObject {
        id: appTheme
        property string name: root.currentThemeMode
        property bool   isDark:          name === "dark"

        // Surface Colors (Luxury Warm Beige & Off-White for Light Mode; Obsidian Dark for Dark Mode)
        property color  bg:              isDark ? "#08080C" : "#F4F0E8"
        property color  sidebar:         isDark ? "#0D0D14" : "#EAE5DB"
        property color  surface:         isDark ? "#12121A" : "#FAF7F2"
        property color  surfaceElevated: isDark ? "#171722" : "#EFEAE0"
        property color  surface2:        isDark ? "#1D1D2C" : "#E7E1D6"
        property color  surfaceGlass:    isDark ? Qt.rgba(0.07, 0.07, 0.11, 0.90) : Qt.rgba(0.98, 0.97, 0.95, 0.94)
        property color  surfaceGlassElevated: isDark ? Qt.rgba(0.10, 0.10, 0.16, 0.94) : Qt.rgba(0.94, 0.92, 0.88, 0.96)

        // Borders & Specular Edge Lighting
        property color  border_:         isDark ? "#252538" : "#D6CFBF"
        property color  borderSubtle:    isDark ? "#191926" : "#E2DCce"
        property color  borderHover:     isDark ? "#3B3B56" : "#BDB4A0"
        property color  borderGlass:     isDark ? Qt.rgba(0.40, 0.40, 0.55, 0.6) : Qt.rgba(0.80, 0.77, 0.72, 0.8)
        property color  borderGlow:      isDark ? Qt.rgba(0.65, 0.35, 1.0, 0.45) : Qt.rgba(0.55, 0.35, 0.85, 0.35)

        // Typography (Warm Espresso / Stone Charcoal for Light Mode)
        property color  textPrimary:     isDark ? "#F8F8FC" : "#1C1917"
        property color  textSecondary:   isDark ? "#9E9EBA" : "#57534E"
        property color  textMuted:       isDark ? "#686884" : "#78716C"

        // Vibrant Logo-Matched Purple & Studio Accents
        property color  accent:          isDark ? "#A855F7" : "#7C3AED"  // Metallic Ultraviolet
        property color  accentHover:     isDark ? "#C084FC" : "#6D28D9"
        property color  accentSoft:      isDark ? "#2B1749" : "#EDE9FE"

        property color  cyan:            isDark ? "#06B6D4" : "#0284C7"  // Cyber Cyan
        property color  cyanSoft:        isDark ? "#083344" : "#E0F2FE"

        property color  success:         isDark ? "#10B981" : "#059669"  // Aurora Mint
        property color  successSoft:     isDark ? "#064E3B" : "#D1FAE5"

        property color  warning:         isDark ? "#F59E0B" : "#D97706"  // Solar Amber
        property color  warningSoft:     isDark ? "#451A03" : "#FEF3C7"

        property color  danger:          isDark ? "#F43F5E" : "#E11D48"  // Crimson Rose
        property color  dangerSoft:      isDark ? "#4C0519" : "#FFE4E6"

        property color  info:            isDark ? "#38BDF8" : "#0284C7"
        property color  infoSoft:        isDark ? "#082F49" : "#E0F2FE"

        property color  camA:            isDark ? "#818CF8" : "#4F46E5"
        property color  camASoft:        isDark ? Qt.rgba(0.51, 0.55, 0.97, 0.16) : Qt.rgba(0.31, 0.27, 0.9, 0.12)
        property color  camB:            isDark ? "#F472B6" : "#DB2777"
        property color  camBSoft:        isDark ? Qt.rgba(0.96, 0.45, 0.71, 0.16) : Qt.rgba(0.86, 0.15, 0.47, 0.12)
        property color  matchedTag:      isDark ? "#34D399" : "#059669"
        property color  dryRunTag:       isDark ? "#38BDF8" : "#0284C7"
    }

    // ── Master Studio Tools Definition & Order ────────────────────────────────
    // 💡 REORDER ANY ITEM HERE TO AUTOMATICALLY REORDER BOTH SIDEBAR & OVERVIEW PIPELINE:
    property var studioTools: [
        { key: "pvSeparator",          icon: "box",     label: "PV Separator",        color: "#06B6D4", bgSoft: "#F0F9FF", desc: "32x RAW Extraction" },
        { key: "photoMatcher",         icon: "photo",   label: "Photo Status Tagger", color: "#8B5CF6", bgSoft: "#F3EEFC", desc: "_U & _R Tagging" },
        { key: "videoTransfer",        icon: "video",   label: "Sync Photo Video",    color: "#10B981", bgSoft: "#ECFDF5", desc: "Sequence Pairing" },
        { key: "thumbnailSeparator",   icon: "thumbs",  label: "Thumbnail Shifter",   color: "#0D9488", bgSoft: "#F0FDFA", desc: "_P & _V Folder Shift" },
        { key: "remainingCollector",   icon: "layers",  label: "Remaining Shifter",   color: "#EC4899", bgSoft: "#FDF2F8", desc: "Consolidation" },
        { key: "excelMerger",          icon: "report",  label: "Report Merger",       color: "#F59E0B", bgSoft: "#FFFBEB", desc: "Delivery Package" }
    ]

    // ── Helper to Persist Config Changes ──────────────────────────────────────
    function persistAppConfig(key, val) {
        if (typeof photoEngine !== "undefined" && photoEngine) {
            var cfg = Object.assign({}, photoEngine.config || {})
            cfg[key] = val
            photoEngine.saveConfig(cfg)
        }
    }

    // ── Main Desktop Layout ───────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Sidebar Navigation (236px) ────────────────────────────────────────
        Sidebar {
            id: sidebar
            theme: appTheme
            toolsModel: root.studioTools
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
                    root.persistAppConfig("theme", next)
                }
                onZoomIn: root.zoomIn()
                onZoomOut: root.zoomOut()
                onResetZoom: root.resetZoom()
            }

            // ── Isolated Responsive Zoom Viewport ─────────────────────────────
            Item {
                id: zoomViewportContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // Scaled inner canvas with inverse dimensioning
                Item {
                    id: zoomScaledContent
                    width: zoomViewportContainer.width / root.zoomLevel
                    height: zoomViewportContainer.height / root.zoomLevel
                    scale: root.zoomLevel
                    transformOrigin: Item.TopLeft

                    Behavior on scale {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    // ── Page Switcher Area with Staggered Slide-Fade ───────────
                    Item {
                        id: pageContainer
                        anchors.fill: parent

                        property int targetIndex: {
                            if (root.activePage === "overview")           return 0
                            if (root.activePage === "photoMatcher")       return 1
                            if (root.activePage === "videoTransfer")      return 2
                            if (root.activePage === "pvSeparator")        return 3
                            if (root.activePage === "remainingCollector") return 4
                            if (root.activePage === "googleDriveMain" || root.activePage === "googleDriveThumbs") return 5
                            if (root.activePage === "activity")           return 6
                            if (root.activePage === "excelMerger")        return 7
                            if (root.activePage === "thumbnailSeparator") return 8
                            return 0
                        }

                        OverviewPage {
                            id: pageOverview
                            anchors.fill: parent
                            theme: appTheme
                            toolsModel: root.studioTools
                            enabled: pageContainer.targetIndex === 0
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 0 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 0 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            onNavigate: (p) => root.activePage = p
                        }

                        PhotoMatcherPage {
                            id: pagePhoto
                            anchors.fill: parent
                            theme: appTheme
                            engine: typeof photoEngine !== "undefined" ? photoEngine : null
                            dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                            enabled: pageContainer.targetIndex === 1
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 1 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 1 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }

                        VideoTransferPage {
                            id: pageVideo
                            anchors.fill: parent
                            theme: appTheme
                            engine: typeof videoEngine !== "undefined" ? videoEngine : null
                            dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                            enabled: pageContainer.targetIndex === 2
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 2 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 2 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }

                        PVSeparatorPage {
                            id: pagePV
                            anchors.fill: parent
                            theme: appTheme
                            engine: typeof pvSeparatorEngine !== "undefined" ? pvSeparatorEngine : null
                            dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                            enabled: pageContainer.targetIndex === 3
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 3 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 3 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }

                        ThumbnailSeparatorPage {
                            id: pageThumbSep
                            anchors.fill: parent
                            theme: appTheme
                            engine: typeof thumbSeparatorEngine !== "undefined" ? thumbSeparatorEngine : null
                            dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                            enabled: pageContainer.targetIndex === 8
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 8 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 8 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }

                        RemainingCollectorPage {
                            id: pageRemaining
                            anchors.fill: parent
                            theme: appTheme
                            engine: typeof remainingEngine !== "undefined" ? remainingEngine : null
                            dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                            enabled: pageContainer.targetIndex === 4
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 4 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 4 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }

                        Loader {
                            id: pageDriveLoader
                            anchors.fill: parent
                            enabled: pageContainer.targetIndex === 5
                            visible: pageContainer.targetIndex === 5
                            active: pageContainer.targetIndex === 5
                            sourceComponent: Component {
                                GoogleDrivePage {
                                    anchors.fill: parent
                                    theme: appTheme
                                    engine: typeof driveEngine !== "undefined" ? driveEngine : null
                                    dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                                    activeDriveTab: root.activePage === "googleDriveThumbs" ? "thumbnails" : "main"
                                }
                            }
                        }

                        ActivityPage {
                            id: pageActivity
                            anchors.fill: parent
                            theme: appTheme
                            enabled: pageContainer.targetIndex === 6
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 6 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 6 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }

                        ExcelMergerPage {
                            id: pageExcelMerger
                            anchors.fill: parent
                            theme: appTheme
                            engine: typeof excelMergerEngine !== "undefined" ? excelMergerEngine : null
                            dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
                            enabled: pageContainer.targetIndex === 7
                            visible: opacity > 0.02
                            opacity: pageContainer.targetIndex === 7 ? 1.0 : 0.0
                            y: pageContainer.targetIndex === 7 ? 0 : 8
                            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                        }
                    }
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
            root.persistAppConfig("theme", t)
        }
    }

    // ── Global Toast Notification ─────────────────────────────────────────────
    ToastNotification { id: globalToast; theme: appTheme }

    // ── Responsive Zoom Controller & Presets ──────────────────────────────────
    function setZoom(val) {
        var rounded = Math.min(1.5, Math.max(0.7, Math.round(val * 10) / 10))
        root.zoomLevel = rounded
        root.persistAppConfig("zoomLevel", rounded)
        zoomHud.show()
    }

    function zoomIn() {
        root.setZoom(root.zoomLevel + 0.1)
    }

    function zoomOut() {
        root.setZoom(root.zoomLevel - 0.1)
    }

    function resetZoom() {
        root.setZoom(1.0)
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
        height: 34
        width: zoomHudRow.implicitWidth + 24
        radius: 8
        color: appTheme.surfaceElevated
        border.color: appTheme.borderGlow
        border.width: 1.5
        opacity: 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 180 } }

        Timer {
            id: hudTimer; interval: 2000; repeat: false
            onTriggered: zoomHud.opacity = 0
        }

        function show() {
            zoomHud.opacity = 0.98
            hudTimer.restart()
        }

        RowLayout {
            id: zoomHudRow
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "🔍  " + Math.round(root.zoomLevel * 100) + "%"
                font.pixelSize: 12
                font.weight: Font.Black
                font.family: "Consolas, monospace"
                color: appTheme.textPrimary
            }

            Rectangle {
                visible: Math.round(root.zoomLevel * 100) !== 100
                height: 22
                width: resetLbl.implicitWidth + 12
                radius: 6
                color: appTheme.accentSoft
                border.color: appTheme.accent
                border.width: 1

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

    // ── Cinematic Startup Splash Screen ───────────────────────────────────────
    SplashScreen {
        id: splashScreen
        theme: appTheme
    }
}
