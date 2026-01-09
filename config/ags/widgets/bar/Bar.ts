/* global imports */
imports.gi.versions.Astal = "4.0";
imports.gi.versions.Gtk = "4.0"; // Добавили явно

const Astal = imports.gi.Astal;
const Gtk = imports.gi.Gtk;

import { Workspaces } from "./Workspaces";
import { Clock } from "./Clock";
import { SysTray } from "./SysTray";

export function Bar(monitor: number = 0) {
    return new Astal.Window({
        name: `bar-${monitor}`,
        monitor,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
        child: new Gtk.CenterBox({
            css_name: "bar-content",
            start_widget: new Gtk.Box({
                halign: Gtk.Align.START,
                children: [Workspaces()],
            }),
            center_widget: new Gtk.Box({
                halign: Gtk.Align.CENTER,
                children: [Clock()],
            }),
            end_widget: new Gtk.Box({
                halign: Gtk.Align.END,
                children: [SysTray()],
            }),
        }),
    });
}