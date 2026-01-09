/* global imports */
imports.gi.versions.Astal = "4.0";

const Astal = imports.gi.Astal;
const GLib = imports.gi.GLib;

const HOME = GLib.get_home_dir();

export const paths = {
    home: HOME,
    // УБРАЛИ глобальную переменную app, теперь все через геттеры
    get config() {
        const app = Astal.Application.get_default();
        // Используем свойство config_dir вместо метода
        return app ? app.config_dir : `${HOME}/.config/ags`;
    },
    cache: `${HOME}/.cache/ags`,
    wal: `${HOME}/.cache/wal/colors.scss`,
    get scss() { 
        return `${this.config}/scss/main.scss`; 
    },
    tempCss: `/tmp/ags-style.css`,
};

export const options = {
    monitor: 0,
    theme: {
        radius: 16,
        blur: 10,
        padding: 8,
        spacing: 12,
    },
    bar: {
        position: "top" as const,
        height: 36,
        spacing: 8,
        margin: [8, 12, 0, 12], 
        floating: true,
    },
};