import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property string bahaiDate: "Loading…"
    readonly property string helperCommand: "python3 " + plasmoid.file("code", "get_bahai_date.py")
    property QtObject execSource: null

    function createExecDataSource() {
        const plasma6Source = 'import QtQuick; import org.kde.plasma.plasma5support as Plasma5Support; Plasma5Support.DataSource { engine: "executable" }';
        const plasma5Source = 'import QtQuick; import org.kde.plasma.core as PlasmaCore; PlasmaCore.DataSource { engine: "executable" }';

        try {
            root.execSource = Qt.createQmlObject(plasma6Source, root, "execSourcePlasma6");
        } catch (plasma6Error) {
            try {
                root.execSource = Qt.createQmlObject(plasma5Source, root, "execSourcePlasma5");
            } catch (plasma5Error) {
                root.bahaiDate = "Error: failed to load DataSource";
            }
        }
    }

    function refreshDate() {
        if (!root.execSource) {
            root.bahaiDate = "Error: No executable data source";
            return;
        }

        root.execSource.connectSource(root.helperCommand);
    }

    preferredRepresentation: compactRepresentation

    compactRepresentation: Item {
        Layout.minimumWidth: Math.max(label.implicitWidth, Kirigami.Units.gridUnit * 8)
        Layout.minimumHeight: Math.max(label.implicitHeight, Kirigami.Units.gridUnit * 3)

        Kirigami.Heading {
            id: label
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            text: root.bahaiDate
            level: 4
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: fullLabel.implicitWidth + Kirigami.Units.gridUnit
        Layout.minimumHeight: fullLabel.implicitHeight + Kirigami.Units.gridUnit

        Kirigami.Heading {
            id: fullLabel
            anchors.centerIn: parent
            text: root.bahaiDate
            level: 1
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    Connections {
        target: root.execSource

        function onNewData(sourceName, data) {
            const out = String(data["stdout"] || "").trim();
            const err = String(data["stderr"] || "").trim();
            const exitCode = data["exit code"];
            const hasExitCode = exitCode !== undefined;

            // Ignore empty intermediary updates, including exit-code-only updates.
            // Some Plasma versions deliver stdout/stderr in a subsequent emission.
            if (out.length === 0 && err.length === 0) {
                if (hasExitCode && Number(exitCode) !== 0) {
                    root.bahaiDate = "Error: command failed (" + exitCode + ")";
                    root.execSource.disconnectSource(sourceName);
                }
                return;
            }

            if (out.length > 0) {
                root.bahaiDate = out;
            } else {
                root.bahaiDate = "Error: " + err;
            }

            root.execSource.disconnectSource(sourceName);
        }
    }

    Component.onCompleted: {
        createExecDataSource();
        refreshDate();
    }

    Timer {
        interval: 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            root.refreshDate();
        }
    }
}
