/* global imports */
imports.gi.versions.Astal = "4.0";
imports.gi.versions.AstalIO = "0.1";
imports.gi.versions.Gtk = "4.0";

const Astal = imports.gi.Astal;
const AstalIO = imports.gi.AstalIO;
const Gtk = imports.gi.Gtk;

const { Variable } = AstalIO;

export function Clock() {
    const time = Variable("").poll(1000, 'date "+%H:%M:%S"');

    return new Gtk.Label({
        css_name: "clock",
        // Убедись, что bind() используется правильно для свойства label
        label: time.bind(),
    });
}