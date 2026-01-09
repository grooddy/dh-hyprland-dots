/* global imports */
imports.gi.versions.Astal = "3.0";
imports.gi.versions.Gtk = "3.0";
imports.gi.versions.AstalHyprland = "0.1";
imports.gi.versions.AstalTray = "0.1";

const { Astal, Gtk, GLib, AstalHyprland, AstalTray, Gio } = imports.gi;

const HOME = GLib.get_home_dir();
const paths = {
    config: `${HOME}/.config/ags`,
    wal: `${HOME}/.cache/wal/colors.scss`,
    tempCss: `/tmp/ags-style.css`
};

function exec(cmd: string[]) {
    try {
        GLib.spawn_command_line_async(cmd.join(" "));
    } catch (e) { console.error(e); }
}

// --- ВИДЖЕТЫ ---

function Workspaces() {
    const hypr = AstalHyprland.get_default();
    const box = new Gtk.Box({ spacing: 4 });
    box.get_style_context().add_class("workspaces");

    for (let id = 1; id <= 10; id++) {
        const btn = new Gtk.Button({ label: `${id}` });
        btn.get_style_context().add_class("workspace");
        btn.connect("clicked", () => exec([`hyprctl dispatch workspace ${id}`]));
        box.add(btn);
    }
    return box;
}

function SysTray() {
    try {
        const tray = AstalTray.get_default();
        const box = new Gtk.Box({ spacing: 8 });
        box.get_style_context().add_class("tray");
        
        const update = () => {
            box.get_children().forEach(child => box.remove(child));
            tray.get_items().forEach(item => {
                const img = Gtk.Image.new_from_gicon(item.gicon, Gtk.IconSize.MENU);
                const btn = new Gtk.Button({ child: img });
                btn.connect("clicked", () => item.activate(0, 0));
                box.add(btn);
            });
            box.show_all();
        };

        tray.connect("item-added", update);
        tray.connect("item-removed", update);
        update();
        return box;
    } catch (e) { return new Gtk.Box(); }
}

function Clock() {
    const label = new Gtk.Label();
    label.get_style_context().add_class("clock");
    
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
        label.label = new Date().toLocaleTimeString('ru-RU', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        return true;
    });
    return label;
}

// --- ОКНО ПАНЕЛИ ---

function Bar(monitor: number) {
    const win = new Astal.Window({
        name: `tahoe-bar`,
        monitor,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
    });

    const content = new Gtk.Box({ 
        homogeneous: false,
        spacing: 0
    });
    content.get_style_context().add_class("bar-content");

    const start = new Gtk.Box({ halign: Gtk.Align.START });
    const center = new Gtk.Box({ halign: Gtk.Align.CENTER });
    const end = new Gtk.Box({ halign: Gtk.Align.END });

    start.add(Workspaces());
    center.add(Clock());
    end.add(SysTray());

    // В GTK3 эмулируем CenterBox через расширение центрального блока
    content.pack_start(start, true, true, 10);
    content.pack_start(center, true, true, 10);
    content.pack_start(end, true, true, 10);

    win.add(content);
    win.show_all();
    return win;
}

// --- ПРИЛОЖЕНИЕ ---

const app = new Astal.Application({ instance_name: "tahoe_gtk3" });

app.connect("activate", () => {
    app.hold();
    console.log("--- Tahoe Shell: Starting (GTK3 Mode) ---");
    
    // 1. Подготовка файлов и Sass
    try {
        GLib.mkdir_with_parents(GLib.path_get_dirname(paths.tempCss), 0o755);
        const pathFile = Gio.File.new_for_path(`${paths.config}/scss/_paths.scss`);
        pathFile.replace_contents(`$wal-path: "${paths.wal}";`, null, false, Gio.FileCreateFlags.NONE, null);
        
        console.log("[Sass] Compiling...");
        exec(["sass", "--no-source-map", `${paths.config}/scss/main.scss`, paths.tempCss]);
    } catch (err) {
        console.error("Sass Error:", err);
    }

    // 2. Запуск бара
    Bar(0);

    // 3. Применение CSS
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
        console.log("[Style] Applying CSS...");
        app.apply_css(paths.tempCss);
        console.log("--- Tahoe Shell: Ready ---");
        return false;
    });
});

app.run([]);