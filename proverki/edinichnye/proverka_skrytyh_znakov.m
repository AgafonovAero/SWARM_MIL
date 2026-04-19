function proverka_skrytyh_znakov(koren_proekta)
spisok_failov = poluchit_spisok_failov(koren_proekta, {'.m', '.md', '.json'});

for nomer_faila = 1:numel(spisok_failov)
    proverit_fail(spisok_failov{nomer_faila});
end

soobshchenie('Скрытые управляющие знаки в текстовых файлах проекта не обнаружены.');
end

function spisok_failov = poluchit_spisok_failov(koren_proekta, rasshireniya)
spisok_failov = {};

for nomer_rasshireniya = 1:numel(rasshireniya)
    maska = ['**/*' rasshireniya{nomer_rasshireniya}];
    naidennye_faily = dir(fullfile(koren_proekta, maska));

    for nomer_faila = 1:numel(naidennye_faily)
        spisok_failov{end + 1} = fullfile( ... %#ok<AGROW>
            naidennye_faily(nomer_faila).folder, ...
            naidennye_faily(nomer_faila).name);
    end
end

spisok_failov = sort(unique(spisok_failov));
end

function proverit_fail(put_k_failu)
baity = prochitat_baity(put_k_failu);
proverit_otsutstvie_bom(baity, put_k_failu);

try
    tekst = native2unicode(baity.', 'UTF-8');
catch oshibka_dekodirovaniya
    error('%s', sprintf( ...
        'Файл %s не удалось декодировать как UTF-8. Причина: %s', ...
        put_k_failu, oshibka_dekodirovaniya.message));
end

kody_simvolov = double(tekst);
for nomer_simvola = 1:numel(kody_simvolov)
    kod_simvola = kody_simvolov(nomer_simvola);

    if kod_simvola == 13
        vyzvat_oshibku_znaka( ...
            put_k_failu, nomer_simvola, kod_simvola, ...
            'Обнаружен запрещенный возврат каретки.');
    end

    if any(kod_simvola == [hex2dec('0085'), hex2dec('2028'), hex2dec('2029')])
        vyzvat_oshibku_znaka( ...
            put_k_failu, nomer_simvola, kod_simvola, ...
            'Обнаружен нестандартный разделитель строк.');
    end

    if yavlyaetsya_zapreshchennym_simvolom(kod_simvola)
        vyzvat_oshibku_znaka( ...
            put_k_failu, nomer_simvola, kod_simvola, ...
            'Обнаружен скрытый управляющий знак.');
    end
end
end

function baity = prochitat_baity(put_k_failu)
identifikator = fopen(put_k_failu, 'rb');
if identifikator == -1
    error('%s', sprintf( ...
        'Не удалось открыть файл для проверки скрытых знаков: %s', ...
        put_k_failu));
end

ochistka = onCleanup(@() fclose(identifikator));
baity = fread(identifikator, Inf, '*uint8');
clear ochistka
end

function proverit_otsutstvie_bom(baity, put_k_failu)
if numel(baity) >= 3 && isequal(baity(1:3).', [239 187 191])
    vyzvat_oshibku_znaka( ...
        put_k_failu, 1, hex2dec('FEFF'), ...
        'Обнаружен запрещенный знак порядка байтов в начале файла.');
end
end

function rezultat = yavlyaetsya_zapreshchennym_simvolom(kod_simvola)
zapreshennye_kody = [ ...
    hex2dec('00AD') ...
    hex2dec('061C') ...
    hex2dec('200B') ...
    hex2dec('200C') ...
    hex2dec('200D') ...
    hex2dec('200E') ...
    hex2dec('200F') ...
    hex2dec('202A') ...
    hex2dec('202B') ...
    hex2dec('202C') ...
    hex2dec('202D') ...
    hex2dec('202E') ...
    hex2dec('2066') ...
    hex2dec('2067') ...
    hex2dec('2068') ...
    hex2dec('2069') ...
    hex2dec('FEFF')];

rezultat = ismember(kod_simvola, zapreshennye_kody) ...
    || ((kod_simvola >= 0 && kod_simvola <= 31) && ~ismember(kod_simvola, [9 10])) ...
    || (kod_simvola >= 127 && kod_simvola <= 159);
end

function vyzvat_oshibku_znaka(put_k_failu, nomer_simvola, kod_simvola, prichina)
error('%s', sprintf([ ...
    '%s%s' ...
    'Файл: %s.%s' ...
    'Номер символа: %d.%s' ...
    'Код знака: U+%04X.%s' ...
    'Название: %s.'], ...
    prichina, newline, ...
    put_k_failu, newline, ...
    nomer_simvola, newline, ...
    kod_simvola, newline, ...
    poluchit_nazvanie_znaka(kod_simvola)));
end

function nazvanie_znaka = poluchit_nazvanie_znaka(kod_simvola)
switch kod_simvola
    case 9
        nazvanie_znaka = 'символ табуляции';
    case 13
        nazvanie_znaka = 'возврат каретки';
    case hex2dec('0085')
        nazvanie_znaka = 'нестандартный перевод строки';
    case hex2dec('00AD')
        nazvanie_znaka = 'мягкий перенос';
    case hex2dec('061C')
        nazvanie_znaka = 'арабская метка направления письма';
    case hex2dec('200B')
        nazvanie_znaka = 'невидимый пробел';
    case hex2dec('200C')
        nazvanie_znaka = 'нулевой знак без соединения';
    case hex2dec('200D')
        nazvanie_znaka = 'нулевой знак соединения';
    case hex2dec('200E')
        nazvanie_znaka = 'знак направления письма слева направо';
    case hex2dec('200F')
        nazvanie_znaka = 'знак направления письма справа налево';
    case hex2dec('2028')
        nazvanie_znaka = 'разделитель строк';
    case hex2dec('2029')
        nazvanie_znaka = 'разделитель абзацев';
    case hex2dec('202A')
        nazvanie_znaka = 'встраивание направления слева направо';
    case hex2dec('202B')
        nazvanie_znaka = 'встраивание направления справа налево';
    case hex2dec('202C')
        nazvanie_znaka = 'снятие встраивания направления';
    case hex2dec('202D')
        nazvanie_znaka = 'переопределение направления слева направо';
    case hex2dec('202E')
        nazvanie_znaka = 'переопределение направления справа налево';
    case hex2dec('2066')
        nazvanie_znaka = 'изолятор направления слева направо';
    case hex2dec('2067')
        nazvanie_znaka = 'изолятор направления справа налево';
    case hex2dec('2068')
        nazvanie_znaka = 'изолятор сильного направления';
    case hex2dec('2069')
        nazvanie_znaka = 'завершение изоляции направления';
    case hex2dec('FEFF')
        nazvanie_znaka = 'знак порядка байтов';
    otherwise
        nazvanie_znaka = 'прочий управляющий символ';
end
end
