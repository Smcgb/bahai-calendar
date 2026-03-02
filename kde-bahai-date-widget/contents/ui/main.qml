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
        Layout.minimumWidth: label.implicitWidth + Kirigami.Units.largeSpacing * 2
        Layout.minimumHeight: label.implicitHeight + Kirigami.Units.largeSpacing * 2

        Kirigami.Heading {
            id: label
            anchors.centerIn: parent
            text: root.bahaiDate
            level: 3
            wrapMode: Text.NoWrap
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
            const out = (data["stdout"] || "").trim();
            const err = (data["stderr"] || "").trim();

            if (out.length > 0) {
                root.bahaiDate = out;
            } else if (err.length > 0) {
                root.bahaiDate = "Error: " + err;
            } else {
                root.bahaiDate = "No date output";
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
