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

spisok_failov = sort(spisok_failov);
end

function proverit_markdown_fail(put_k_failu)
baity = prochitat_baity(put_k_failu);
if isempty(baity)
    error('%s', sprintf('Файл Markdown пустой: %s', put_k_failu));
end

if numel(baity) >= 3 && isequal(baity(1:3).', [239 187 191])
    error('%s', sprintf( ...
        'В файле Markdown %s обнаружен запрещенный знак порядка байтов.', ...
        put_k_failu));
end

if any(baity == 13)
    error('%s', sprintf( ...
        'В файле Markdown %s обнаружен запрещенный возврат каретки. Допустим только LF.', ...
        put_k_failu));
end

tekst = native2unicode(baity.', 'UTF-8');
if strlength(strtrim(string(tekst))) == 0
    error('%s', sprintf('Файл Markdown пустой: %s', put_k_failu));
end

stroki = regexp(tekst, '\n', 'split');
for nomer_stroki = 1:numel(stroki)
    tekushchaya_stroka = stroki{nomer_stroki};

    proverit_polozhenie_zagolovka(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_chislo_zagolovkov_v_stroke(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_spiski_v_stroke(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_dlinu_stroki(put_k_failu, tekushchaya_stroka, nomer_stroki);
    proverit_pustuyu_stroku_pered_zagolovkom(put_k_failu, stroki, nomer_stroki);
    proverit_pustuyu_stroku_posle_zagolovka(put_k_failu, stroki, nomer_stroki);
end
end

function proverit_polozhenie_zagolovka(put_k_failu, stroka, nomer_stroki)
if ~isempty(regexp(stroka, '^\s+#', 'once'))
    error('%s', sprintf( ...
        'Заголовок должен начинаться с начала строки. Файл: %s. Строка: %d.', ...
        put_k_failu, nomer_stroki));
end
end

function proverit_chislo_zagolovkov_v_stroke(put_k_failu, stroka, nomer_stroki)
if isempty(regexp(stroka, '^#{1,6}\s+', 'once'))
    return
end

if ~isempty(regexp(stroka, '\s+#{1,6}\s+', 'once'))
    error('%s', sprintf( ...
        'В одной строке Markdown обнаружено несколько заголовков. Файл: %s. Строка: %d.', ...
        put_k_failu, nomer_stroki));
end
end

function proverit_spiski_v_stroke(put_k_failu, stroka, nomer_stroki)
est_dva_markera_spiska = ...
    ~isempty(regexp(stroka, '^\s*[-*+]\s+.+\s{2,}[-*+]\s+\S', 'once'));
est_dva_markera_numeracii = ...
    ~isempty(regexp(stroka, '^\s*\d+\.\s+.+\s{2,}\d+\.\s+\S', 'once'));

if est_dva_markera_spiska || est_dva_markera_numeracii
    error('%s', sprintf( ...
        'В строке Markdown обнаружено несколько пунктов списка. Файл: %s. Строка: %d.', ...
        put_k_failu, nomer_stroki));
end
end

function proverit_dlinu_stroki(put_k_failu, stroka, nomer_stroki)
if strlength(string(stroka)) <= 240
    return
end

est_isklyuchenie = ...
    contains(stroka, 'http://') || ...
    contains(stroka, 'https://') || ...
    ~isempty(regexp(stroka, '[A-Za-z]:\\', 'once')) || ...
    ~isempty(regexp(stroka, '(^|[\s(])/[^\s]+', 'once'));

if ~est_isklyuchenie
    error('%s', sprintf( ...
        'Строка Markdown длиннее 240 символов. Файл: %s. Строка: %d.', ...
        put_k_failu, nomer_stroki));
end
end

function proverit_pustuyu_stroku_pered_zagolovkom(put_k_failu, stroki, nomer_stroki)
tekushchaya_stroka = stroki{nomer_stroki};
est_krupnyi_zagolovok = ~isempty(regexp(tekushchaya_stroka, '^(#|##)\s+', 'once'));

if ~est_krupnyi_zagolovok || nomer_stroki == 1
    return
end

predydushchaya_stroka = stroki{nomer_stroki - 1};
if strlength(strtrim(string(predydushchaya_stroka))) ~= 0
    error('%s', sprintf( ...
        'Перед заголовком уровня # или ## должна быть пустая строка. Файл: %s. Строка: %d.', ...
        put_k_failu, nomer_stroki));
end
end

function proverit_pustuyu_stroku_posle_zagolovka(put_k_failu, stroki, nomer_stroki)
tekushchaya_stroka = stroki{nomer_stroki};
est_zagolovok = ~isempty(regexp(tekushchaya_stroka, '^#{1,6}\s+', 'once'));

if ~est_zagolovok || nomer_stroki == numel(stroki)
    return
end

sleduyushchaya_stroka = stroki{nomer_stroki + 1};
if strlength(strtrim(string(sleduyushchaya_stroka))) ~= 0
    error('%s', sprintf( ...
        'После заголовка должна быть пустая строка. Файл: %s. Строка: %d.', ...
        put_k_failu, nomer_stroki));
end
end

function baity = prochitat_baity(put_k_failu)
identifikator = fopen(put_k_failu, 'rb');
if identifikator == -1
    error('%s', sprintf('Не удалось открыть файл Markdown: %s', put_k_failu));
end

ochistka = onCleanup(@() fclose(identifikator));
baity = fread(identifikator, Inf, '*uint8');
clear ochistka
end
