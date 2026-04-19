function proverka_skrytyh_znakov(koren_proekta)
spisok_failov = poluchit_spisok_tekstovyh_failov(koren_proekta, {'.m', '.md'});

for nomer_faila = 1:numel(spisok_failov)
    proverit_fail_na_skrytye_znaki(spisok_failov{nomer_faila});
end

soobshchenie('Скрытые управляющие знаки в текстовых файлах не обнаружены.');
end

function spisok_failov = poluchit_spisok_tekstovyh_failov(koren_proekta, rasshireniya)
spisok_failov = {};

for nomer_rasshireniya = 1:numel(rasshireniya)
    maska = ['**/*' rasshireniya{nomer_rasshireniya}];
    naidennye_faily = dir(fullfile(koren_proekta, maska));

    for nomer_faila = 1:numel(naidennye_faily)
        spisok_failov{end + 1} = fullfile( ...
            naidennye_faily(nomer_faila).folder, ...
            naidennye_faily(nomer_faila).name); %#ok<AGROW>
    end
end

spisok_failov = unique(spisok_failov);
end

function proverit_fail_na_skrytye_znaki(put_k_failu)
baity = prochitat_baity(put_k_failu);
tekst = native2unicode(baity.', 'UTF-8');
kody_simvolov = double(tekst);
est_bom_v_nachale = est_dopustimyi_bom_v_nachale(baity, kody_simvolov);

for nomer_simvola = 1:numel(kody_simvolov)
    kod_simvola = kody_simvolov(nomer_simvola);

    if kod_simvola == hex2dec('FEFF') && nomer_simvola == 1 && est_bom_v_nachale
        continue
    end

    if ~yavlyaetsya_skrytym_znakom(kod_simvola)
        continue
    end

    soobshchenie_ob_oshibke = sprintf([ ...
        'Обнаружен скрытый управляющий знак в файле %s.%s' ...
        'Номер символа: %d.%s' ...
        'Код знака: U+%04X.%s' ...
        'Название: %s.'], ...
        put_k_failu, newline, ...
        nomer_simvola, newline, ...
        kod_simvola, newline, ...
        nazvanie_znaka(kod_simvola));
    error('%s', soobshchenie_ob_oshibke);
end
end

function baity = prochitat_baity(put_k_failu)
identifikator = fopen(put_k_failu, 'r');
if identifikator == -1
    error('%s', sprintf( ...
        'Не удалось открыть файл для проверки скрытых знаков: %s', ...
        put_k_failu));
end

baity = fread(identifikator, Inf, '*uint8');
fclose(identifikator);
end

function rezultat = est_dopustimyi_bom_v_nachale(baity, kody_simvolov)
rezultat = numel(baity) >= 3 ...
    && isequal(baity(1:3).', [239 187 191]) ...
    && ~isempty(kody_simvolov) ...
    && kody_simvolov(1) == hex2dec('FEFF');
end

function rezultat = yavlyaetsya_skrytym_znakom(kod_simvola)
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

rezultat = ismember(kod_simvola, zapreshennye_kody) ...
    || ((kod_simvola >= 0 && kod_simvola <= 31) && ~ismember(kod_simvola, [9 10 13])) ...
    || (kod_simvola >= 127 && kod_simvola <= 159);
end

function imya = nazvanie_znaka(kod_simvola)
switch kod_simvola
    case hex2dec('00AD')
        imya = 'мягкий перенос';
    case hex2dec('200B')
        imya = 'невидимый пробел';
    case hex2dec('200E')
        imya = 'знак направления письма слева направо';
    case hex2dec('200F')
        imya = 'знак направления письма справа налево';
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
        imya = 'прочий скрытый управляющий знак';
end
end
