/* global imports */
imports.gi.versions.AstalIO = "0.1";
const AstalIO = imports.gi.AstalIO;

import { paths } from "./config";

export async function checkDependencies() {
    console.log("--- System Health Check ---");
    const deps = [
        { name: "sass", critical: true },
        { name: "hyprctl", critical: true },
        { name: "magick", critical: false },
        { name: "pywal", critical: false },
    ];

    let allOk = true;
    for (const dep of deps) {
        try {
            // Используем прямой вызов метода
            await AstalIO.exec_async(["which", dep.name], null); 
            console.log(`[OK] ${dep.name} found.`);
        } catch (err) {
            if (dep.critical) {
                console.error(`[CRITICAL] ${dep.name} is missing!`);
                allOk = false;
            } else {
                console.warn(`[WARNING] ${dep.name} is missing.`);
            }
        }
    }
    console.log("---------------------------");
    return allOk;
}

export function initDirectories() {
    try {
        // Пробуем exec_sync напрямую из AstalIO
        AstalIO.exec_sync(["mkdir", "-p", paths.cache]);
    } catch (err) {
        // Если exec_sync не существует, пробуем просто exec
        try {
            AstalIO.exec(["mkdir", "-p", paths.cache]);
        } catch (e) {
            console.error("Ошибка создания директории кэша:", e);
        }
    }
}