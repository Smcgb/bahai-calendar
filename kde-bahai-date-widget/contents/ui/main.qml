import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property string bahaiDate: "Loading…"
    readonly property string helperCommand: "python3 " + plasmoid.file("code", "get_bahai_date.py")

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

    PlasmaCore.DataSource {
        id: execSource
        engine: "executable"

        onNewData: function (sourceName, data) {
            const out = (data["stdout"] || "").trim();
            const err = (data["stderr"] || "").trim();

            if (out.length > 0) {
                root.bahaiDate = out;
            } else if (err.length > 0) {
                root.bahaiDate = "Error: " + err;
            } else {
                root.bahaiDate = "No date output";
            }

            disconnectSource(sourceName);
        }
    }

    Timer {
        interval: 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            execSource.connectSource(root.helperCommand);
        }
    }
}
