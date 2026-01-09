/* global imports */
imports.gi.versions.Astal = "4.0";
imports.gi.versions.AstalTray = "0.1";
imports.gi.versions.Gtk = "4.0";

const Astal = imports.gi.Astal;
const AstalTray = imports.gi.AstalTray;
const Gtk = imports.gi.Gtk;

export function SysTray() {
    const tray = AstalTray.get_default();

    return new Gtk.Box({
        css_name: "tray",
        // Биндим массив элементов трея к детям Box
        children: tray.bind("items").as(items => items.map(item => {
            if (!item) return null;
            
            const btn = new Gtk.Button({
                css_name: "tray-item",
                child: new Gtk.Image({ 
                    gicon: item.bind("gicon") 
                }),
                tooltip_text: item.bind("tooltip_markup"),
            });
            
            btn.connect("clicked", () => item.activate(0, 0)); 
            return btn;
        }))
    });
}