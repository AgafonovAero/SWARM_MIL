function proverka_skrytyh_znakov(koren_proekta)
spisok_failov = [ ...
    dir(fullfile(koren_proekta, '**', '*.m')); ...
    dir(fullfile(koren_proekta, '**', '*.md'))];

zapreshennye_kody = [ ...
    hex2dec('00AD') ...
    hex2dec('200B') ...
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

for nomer_faila = 1:numel(spisok_failov)
    tekushchii_fail = fullfile(spisok_failov(nomer_faila).folder, spisok_failov(nomer_faila).name);
    baity = prochitat_baity(tekushchii_fail);
    est_dopustimyi_bom_v_nachale = numel(baity) >= 3 && isequal(baity(1:3).', [239 187 191]);
    tekst = native2unicode(baity.', 'UTF-8');
    kody = double(tekst);

    for nomer_simvola = 1:numel(kody)
        kod = kody(nomer_simvola);
        if ~ismember(kod, zapreshennye_kody)
            continue
        end

        if kod == hex2dec('FEFF') && nomer_simvola == 1 && est_dopustimyi_bom_v_nachale
            continue
        end

        error('Обнаружен скрытый управляющий знак "%s" в файле %s. Номер символа: %d.', ...
            nazvanie_znaka(kod), tekushchii_fail, nomer_simvola);
    end
end

soobshchenie('Скрытые управляющие знаки в текстовых файлах не обнаружены.');
end

function baity = prochitat_baity(put_k_failu)
identifikator = fopen(put_k_failu, 'r');
if identifikator == -1
    error('Не удалось открыть файл для проверки скрытых знаков: %s', put_k_failu);
end

baity = fread(identifikator, Inf, '*uint8');
fclose(identifikator);
end

function imya = nazvanie_znaka(kod)
switch kod
    case hex2dec('00AD')
        imya = 'мягкий перенос';
    case hex2dec('200B')
        imya = 'невидимый пробел';
    case hex2dec('200E')
        imya = 'управление направлением письма слева направо';
    case hex2dec('200F')
        imya = 'управление направлением письма справа налево';
    case hex2dec('202A')
        imya = 'встраивание направления слева направо';
    case hex2dec('202B')
        imya = 'встраивание направления справа налево';
    case hex2dec('202C')
        imya = 'снятие встраивания направления';
    case hex2dec('202D')
        imya = 'переопределение направления слева направо';
    case hex2dec('202E')
        imya = 'переопределение направления справа налево';
    case hex2dec('2066')
        imya = 'изолятор направления слева направо';
    case hex2dec('2067')
        imya = 'изолятор направления справа налево';
    case hex2dec('2068')
        imya = 'изолятор сильного направления';
    case hex2dec('2069')
        imya = 'завершение изоляции направления';
    case hex2dec('FEFF')
        imya = 'знак порядка байтов';
    otherwise
        imya = 'неизвестный скрытый знак';
end
end
