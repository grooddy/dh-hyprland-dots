/* global imports */
imports.gi.versions.Astal = "4.0";
imports.gi.versions.AstalHyprland = "0.1";
imports.gi.versions.Gtk = "4.0";

const Astal = imports.gi.Astal;
const AstalHyprland = imports.gi.AstalHyprland;
const Gtk = imports.gi.Gtk;

export function Workspaces() {
    const hypr = AstalHyprland.get_default();

    const workspaces = Array.from({ length: 10 }, (_, i) => i + 1).map(id => {
        const btn = new Gtk.Button({
            css_name: "workspace",
            child: new Gtk.Label({ label: `${id}` }),
        });

        const updateClass = () => {
            if (!hypr) return;
            const activeId = hypr.focused_workspace?.id;
            if (activeId === id) {
                btn.add_css_class("focused");
            } else {
                btn.remove_css_class("focused");
            }
        };

        if (hypr) {
            hypr.connect("notify::focused-workspace", updateClass);
            updateClass();
            btn.connect("clicked", () => hypr.message(`dispatch workspace ${id}`));
        }
        
        return btn;
    });

    return new Gtk.Box({
        css_name: "workspaces",
        children: workspaces,
    });
}