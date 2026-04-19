from __future__ import annotations

import json
import re
import sys
from pathlib import Path


RAZRESHENNYE_RASSHIRENIYA = {".m", ".md", ".json"}
ZAPRESHENNYE_SIMVOLY = {
    0x0085: "нестандартный перевод строки",
    0x00AD: "мягкий перенос",
    0x061C: "арабская метка направления письма",
    0x200B: "невидимый пробел",
    0x200C: "нулевой знак без соединения",
    0x200D: "нулевой знак соединения",
    0x200E: "знак направления письма слева направо",
    0x200F: "знак направления письма справа налево",
    0x2028: "разделитель строк",
    0x2029: "разделитель абзацев",
    0x202A: "встраивание направления слева направо",
    0x202B: "встраивание направления справа налево",
    0x202C: "снятие встраивания направления",
    0x202D: "переопределение направления слева направо",
    0x202E: "переопределение направления справа налево",
    0x2066: "изолятор направления слева направо",
    0x2067: "изолятор направления справа налево",
    0x2068: "изолятор сильного направления",
    0x2069: "завершение изоляции направления",
    0xFEFF: "знак порядка байтов",
}
RE_MD_MULTI_HEADING = re.compile(r"^#{1,6}\s+.*\s+#{1,6}\s+")
RE_MD_MULTI_BULLET = re.compile(r"^\s*[-*+]\s+.+\s{2,}[-*+]\s+\S")
RE_MD_MULTI_NUMBER = re.compile(r"^\s*\d+\.\s+.+\s{2,}\d+\.\s+\S")
RE_FUNCTION_ALLOWED = re.compile(
    r"^function\s+(\[[^\]]+\]|\w+)?\s*=?\s*\w+\s*(\([^)]*\))?\s*$"
)


def main() -> int:
    oshibki: list[str] = []

    for put_k_failu in sorted(Path(".").rglob("*")):
        if ".git" in put_k_failu.parts or not put_k_failu.is_file():
            continue
        if put_k_failu.suffix.lower() not in RAZRESHENNYE_RASSHIRENIYA:
            continue

        oshibki.extend(proverit_fail(put_k_failu))

    if oshibki:
        print("\n".join(oshibki))
        return 1

    print("Проверка целостности текстовых файлов пройдена успешно.")
    return 0


def proverit_fail(put_k_failu: Path) -> list[str]:
    oshibki: list[str] = []
    dannye = put_k_failu.read_bytes()

    if not dannye:
        return [f"{put_k_failu}:1: файл пустой"]

    if dannye.startswith(b"\xef\xbb\xbf"):
        oshibki.append(
            f"{put_k_failu}:1:1: U+FEFF: обнаружен BOM в начале файла"
        )

    nomer_cr = dannye.find(b"\r")
    if nomer_cr != -1:
        stroka, simvol = poluchit_polozhenie_po_baitam(dannye, nomer_cr)
        oshibki.append(
            f"{put_k_failu}:{stroka}:{simvol}: U+000D: обнаружен запрещенный возврат каретки"
        )

    try:
        tekst = dannye.decode("utf-8")
    except UnicodeDecodeError as oshibka:
        return [f"{put_k_failu}: файл не читается как UTF-8: {oshibka}"]

    oshibki.extend(proverit_simvoly(put_k_failu, tekst))

    stroki = tekst.split("\n")
    for nomer_stroki, stroka in enumerate(stroki, 1):
        if put_k_failu.suffix.lower() == ".m":
            oshibki.extend(proverit_stroku_matlab(put_k_failu, nomer_stroki, stroka))
        elif put_k_failu.suffix.lower() == ".md":
            oshibki.extend(proverit_stroku_markdown(put_k_failu, nomer_stroki, stroka))
        elif put_k_failu.suffix.lower() == ".json":
            oshibki.extend(proverit_stroku_json(put_k_failu, nomer_stroki, stroka))

    if put_k_failu.suffix.lower() == ".json":
        try:
            json.loads(tekst)
        except json.JSONDecodeError as oshibka:
            oshibki.append(
                f"{put_k_failu}:{oshibka.lineno}:{oshibka.colno}: JSON не разбирается: {oshibka.msg}"
            )

    return oshibki


def proverit_simvoly(put_k_failu: Path, tekst: str) -> list[str]:
    oshibki: list[str] = []
    nomer_stroki = 1
    nomer_stolbca = 1

    for simvol in tekst:
        kod = ord(simvol)
        if kod == 10:
            nomer_stroki += 1
            nomer_stolbca = 1
            continue

        prichina = None
        if kod in ZAPRESHENNYE_SIMVOLY:
            prichina = ZAPRESHENNYE_SIMVOLY[kod]
        elif kod < 32 and kod != 9:
            prichina = "прочий управляющий символ"
        elif 127 <= kod <= 159:
            prichina = "прочий управляющий символ"

        if prichina is not None:
            oshibki.append(
                f"{put_k_failu}:{nomer_stroki}:{nomer_stolbca}: U+{kod:04X}: {prichina}"
            )

        nomer_stolbca += 1

    return oshibki


def proverit_stroku_matlab(put_k_failu: Path, nomer_stroki: int, stroka: str) -> list[str]:
    oshibki: list[str] = []
    ochishchennaya = stroka.strip()

    if stroka.strip() == "end function":
        oshibki.append(
            f"{put_k_failu}:{nomer_stroki}:1: строка end function запрещена"
        )

    if ochishchennaya.startswith("function ") and not RE_FUNCTION_ALLOWED.match(ochishchennaya):
        oshibki.append(
            f"{put_k_failu}:{nomer_stroki}:1: объявление функции объединено с телом или записано неверно"
        )

    if len(stroka) > 180 and not est_dopustimaya_dlinnaya_stroka(stroka):
        oshibki.append(
            f"{put_k_failu}:{nomer_stroki}:1: строка MATLAB длиннее 180 символов"
        )

    return oshibki


def proverit_stroku_markdown(put_k_failu: Path, nomer_stroki: int, stroka: str) -> list[str]:
    oshibki: list[str] = []

    if RE_MD_MULTI_HEADING.search(stroka):
        oshibki.append(
            f"{put_k_failu}:{nomer_stroki}:1: в одной строке Markdown обнаружено несколько заголовков"
        )

    if RE_MD_MULTI_BULLET.search(stroka) or RE_MD_MULTI_NUMBER.search(stroka):
        oshibki.append(
            f"{put_k_failu}:{nomer_stroki}:1: в одной строке Markdown обнаружено несколько пунктов списка"
        )

    if len(stroka) > 240 and not est_dopustimaya_dlinnaya_stroka(stroka):
        oshibki.append(
            f"{put_k_failu}:{nomer_stroki}:1: строка Markdown длиннее 240 символов"
        )

    return oshibki


def proverit_stroku_json(put_k_failu: Path, nomer_stroki: int, stroka: str) -> list[str]:
    if len(stroka) > 240 and not est_dopustimaya_dlinnaya_stroka(stroka):
        return [
            f"{put_k_failu}:{nomer_stroki}:1: строка JSON длиннее 240 символов"
        ]
    return []


def est_dopustimaya_dlinnaya_stroka(stroka: str) -> bool:
    return (
        "http://" in stroka
        or "https://" in stroka
        or re.search(r"[A-Za-z]:\\", stroka) is not None
        or re.search(r"(^|[\s(])/[^\s]+", stroka) is not None
    )


def poluchit_polozhenie_po_baitam(dannye: bytes, nomer_baita: int) -> tuple[int, int]:
    chast = dannye[: nomer_baita + 1]
    stroka = chast.count(b"\n") + 1
    poslednyaya_stroka = chast.split(b"\n")[-1]
    return stroka, len(poslednyaya_stroka)


if __name__ == "__main__":
    raise SystemExit(main())
