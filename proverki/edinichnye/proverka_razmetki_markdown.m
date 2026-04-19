function proverka_razmetki_markdown(koren_proekta)
spisok_failov = poluchit_markdown_faily(koren_proekta);

for nomer_faila = 1:numel(spisok_failov)
    proverit_markdown_fail(spisok_failov{nomer_faila});
end

soobshchenie('Разметка Markdown в документах соответствует правилам проекта.');
end

function spisok_failov = poluchit_markdown_faily(koren_proekta)
naidennye_faily = dir(fullfile(koren_proekta, '**', '*.md'));
spisok_failov = cell(1, numel(naidennye_faily));

for nomer_faila = 1:numel(naidennye_faily)
    spisok_failov{nomer_faila} = fullfile( ...
        naidennye_faily(nomer_faila).folder, ...
        naidennye_faily(nomer_faila).name);
end
end

function proverit_markdown_fail(put_k_failu)
tekst = fileread(put_k_failu);
if strlength(strtrim(string(tekst))) == 0
    error('%s', sprintf('Файл Markdown пустой: %s', put_k_failu));
end

proverit_skrytye_znaki_v_markdown(put_k_failu);
stroki = regexp(tekst, '\r\n|\n|\r', 'split');

for nomer_stroki = 1:numel(stroki)
    tekushchaya_stroka = stroki{nomer_stroki};

    proverit_polozhenie_zagolovka(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_chislo_zagolovkov_v_stroke(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_spiski_v_stroke(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_dlinu_stroki(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_pustuyu_stroku_pered_krupnym_razdelom(put_k_failu, stroki, nomer_stroki);
end
end

function proverit_polozhenie_zagolovka(put_k_failu, stroka, nomer_stroki)
if ~isempty(regexp(stroka, '^\s+#', 'once'))
    error('%s', sprintf([ ...
        'Заголовок должен начинаться с начала строки в файле %s.%s' ...
        'Номер строки: %d.'], ...
        put_k_failu, newline, nomer_stroki));
end
end

function proverit_chislo_zagolovkov_v_stroke(put_k_failu, stroka, nomer_stroki)
if isempty(regexp(stroka, '^#{1,6}\s+', 'once'))
    return
end

if ~isempty(regexp(stroka, '\s+#{1,6}\s+', 'once'))
    error('%s', sprintf([ ...
        'В одной строке обнаружено несколько заголовков в файле %s.%s' ...
        'Номер строки: %d.'], ...
        put_k_failu, newline, nomer_stroki));
end
end

function proverit_spiski_v_stroke(put_k_failu, stroka, nomer_stroki)
est_dva_markera_spiska = ~isempty(regexp(stroka, '^\s*-\s+.+\s+-\s+\S', 'once'));
est_dva_markera_numeracii = ~isempty(regexp(stroka, '^\s*\d+\.\s+.+\s+\d+\.\s+\S', 'once'));

if est_dva_markera_spiska || est_dva_markera_numeracii
    error('%s', sprintf([ ...
        'В строке Markdown обнаружено несколько пунктов списка в файле %s.%s' ...
        'Номер строки: %d.'], ...
        put_k_failu, newline, nomer_stroki));
end
end

function proverit_dlinu_stroki(put_k_failu, stroka, nomer_stroki)
if strlength(string(stroka)) <= 240
    return
end

est_isklyuchenie = contains(stroka, 'http://') ...
    || contains(stroka, 'https://') ...
    || ~isempty(regexp(stroka, '[A-Za-z]:\\', 'once')) ...
    || ~isempty(regexp(stroka, '/\S{80,}', 'once'));

if ~est_isklyuchenie
    error('%s', sprintf([ ...
        'Обнаружена чрезмерно длинная строка Markdown в файле %s.%s' ...
        'Номер строки: %d.%s' ...
        'Длина строки: %d.'], ...
        put_k_failu, newline, ...
        nomer_stroki, newline, ...
        strlength(string(stroka))));
end
end

function proverit_pustuyu_stroku_pered_krupnym_razdelom(put_k_failu, stroki, nomer_stroki)
tekushchaya_stroka = stroki{nomer_stroki};
est_krupnyi_razdel = ~isempty(regexp(tekushchaya_stroka, '^(#|##)\s+', 'once'));

if ~est_krupnyi_razdel || nomer_stroki == 1
    return
end

predydushchaya_stroka = stroki{nomer_stroki - 1};
if strlength(strtrim(string(predydushchaya_stroka))) ~= 0
    error('%s', sprintf([ ...
        'Перед крупным разделом должна быть пустая строка в файле %s.%s' ...
        'Номер строки: %d.'], ...
        put_k_failu, newline, nomer_stroki));
end
end

function proverit_skrytye_znaki_v_markdown(put_k_failu)
baity = prochitat_baity(put_k_failu);
tekst = native2unicode(baity.', 'UTF-8');
kody_simvolov = double(tekst);
est_bom_v_nachale = numel(baity) >= 3 ...
    && isequal(baity(1:3).', [239 187 191]) ...
    && ~isempty(kody_simvolov) ...
    && kody_simvolov(1) == hex2dec('FEFF');

for nomer_simvola = 1:numel(kody_simvolov)
    kod_simvola = kody_simvolov(nomer_simvola);

    if kod_simvola == hex2dec('FEFF') && nomer_simvola == 1 && est_bom_v_nachale
        continue
    end

    if ~yavlyaetsya_skrytym_znakom(kod_simvola)
        continue
    end

    error('%s', sprintf([ ...
        'В документе %s обнаружен скрытый управляющий знак.%s' ...
        'Номер символа: %d.%s' ...
        'Код знака: U+%04X.%s' ...
        'Название: %s.'], ...
        put_k_failu, newline, ...
        nomer_simvola, newline, ...
        kod_simvola, newline, ...
        nazvanie_znaka(kod_simvola)));
end
end

function baity = prochitat_baity(put_k_failu)
identifikator = fopen(put_k_failu, 'rb');
if identifikator == -1
    error('%s', sprintf('Не удалось открыть файл Markdown: %s', put_k_failu));
end

baity = fread(identifikator, Inf, '*uint8');
fclose(identifikator);
end

function rezultat = yavlyaetsya_skrytym_znakom(kod_simvola)
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
    || ((kod_simvola >= 0 && kod_simvola <= 31) && ~ismember(kod_simvola, [9 10 13])) ...
    || (kod_simvola >= 127 && kod_simvola <= 159);
end

function imya = nazvanie_znaka(kod_simvola)
switch kod_simvola
    case hex2dec('00AD')
        imya = 'мягкий перенос';
    case hex2dec('061C')
        imya = 'арабская метка направления письма';
    case hex2dec('200B')
        imya = 'невидимый пробел';
    case hex2dec('200C')
        imya = 'нулевой знак без соединения';
    case hex2dec('200D')
        imya = 'нулевой знак соединения';
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
