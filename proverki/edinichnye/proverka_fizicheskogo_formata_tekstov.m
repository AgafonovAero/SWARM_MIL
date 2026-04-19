function proverka_fizicheskogo_formata_tekstov(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Не задан корень проекта для проверки физического формата текстов.');
end

spisok_failov = poluchit_spisok_failov(koren_proekta, {'.m', '.md', '.json'});

for nomer_faila = 1:numel(spisok_failov)
    put_k_failu = spisok_failov{nomer_faila};
    [~, ~, rasshirenie] = fileparts(put_k_failu);

    proverit_nepustoi_fail(put_k_failu);
    proverit_standartnye_razdeliteli_strok(put_k_failu);

    switch lower(rasshirenie)
        case '.m'
            proverit_matlab_fail(put_k_failu);
        case '.md'
            proverit_markdown_fail(put_k_failu);
        case '.json'
            proverit_json_fail(put_k_failu);
        otherwise
            error('%s', sprintf( ...
                'Обнаружено неподдерживаемое расширение файла: %s', ...
                put_k_failu));
    end
end

soobshchenie('Физический формат текстовых файлов соответствует правилам проекта.');
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

function proverit_nepustoi_fail(put_k_failu)
baity = prochitat_baity(put_k_failu);
if isempty(baity)
    vyzvat_oshibku_formata(put_k_failu, 1, 'Файл пустой.');
end

try
    tekst = native2unicode(baity.', 'UTF-8');
catch oshibka_dekodirovaniya
    error('%s', sprintf( ...
        'Файл %s не удалось декодировать как UTF-8. Причина: %s', ...
        put_k_failu, oshibka_dekodirovaniya.message));
end

if strlength(strtrim(string(tekst))) == 0
    vyzvat_oshibku_formata( ...
        put_k_failu, 1, ...
        'Файл пустой или содержит только пробельные символы.');
end
end

function proverit_standartnye_razdeliteli_strok(put_k_failu)
baity = prochitat_baity(put_k_failu);
if any(baity == 13)
    nomer_stroki = 1 + sum(baity(1:find(baity == 13, 1, 'first')) == 10);
    vyzvat_oshibku_formata( ...
        put_k_failu, nomer_stroki, ...
        'Обнаружен запрещенный возврат каретки. Допустим только LF.');
end
end

function proverit_matlab_fail(put_k_failu)
stroki = prochitat_stroki_lf(put_k_failu);

for nomer_stroki = 1:numel(stroki)
    stroka = stroki{nomer_stroki};
    ochishchennaya_stroka = strtrim(stroka);

    if ~isempty(regexp(ochishchennaya_stroka, '^end\s+function$', 'once'))
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'В MATLAB-файле запрещена строка с неверным завершением функции.');
    end

    if startsWith(ochishchennaya_stroka, 'function ') ...
            && ~stroka_yavlyaetsya_korrektnym_obyavleniem_funkcii(ochishchennaya_stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'Объявление функции объединено с телом или записано в неверном виде.');
    end

    if strlength(string(stroka)) > 180 && ~razreshena_dlinnaya_stroka(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'Длина строки MATLAB превышает 180 символов.');
    end
end
end

function proverit_markdown_fail(put_k_failu)
stroki = prochitat_stroki_lf(put_k_failu);

for nomer_stroki = 1:numel(stroki)
    stroka = stroki{nomer_stroki};

    if est_neskolko_zagolovkov_v_odnoi_stroke(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'В строке Markdown обнаружено несколько заголовков.');
    end

    if est_neskolko_punktov_spiska_v_odnoi_stroke(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'В строке Markdown обнаружено несколько пунктов списка.');
    end

    if strlength(string(stroka)) > 240 && ~razreshena_dlinnaya_stroka(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'Длина строки Markdown превышает 240 символов.');
    end
end
end

function proverit_json_fail(put_k_failu)
baity = prochitat_baity(put_k_failu);
tekst = native2unicode(baity.', 'UTF-8');
stroki = prochitat_stroki_lf(put_k_failu);

for nomer_stroki = 1:numel(stroki)
    stroka = stroki{nomer_stroki};
    if strlength(string(stroka)) > 240 && ~razreshena_dlinnaya_stroka(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, nomer_stroki, ...
            'Длина строки JSON превышает 240 символов.');
    end
end

try
    jsondecode(tekst);
catch oshibka_razbora
    error('%s', sprintf( ...
        'Файл JSON не удалось разобрать через jsondecode: %s. Причина: %s', ...
        put_k_failu, oshibka_razbora.message));
end
end

function stroki = prochitat_stroki_lf(put_k_failu)
baity = prochitat_baity(put_k_failu);
tekst = native2unicode(baity.', 'UTF-8');
stroki = regexp(tekst, '\n', 'split');
end

function rezultat = stroka_yavlyaetsya_korrektnym_obyavleniem_funkcii(stroka)
shablony = {
    '^function\s+[A-Za-z]\w*\s*(\([^)]*\))?\s*$'
    '^function\s+(?:\[[^\]]+\]|[A-Za-z]\w*)\s*=\s*[A-Za-z]\w*\s*(\([^)]*\))?\s*$'
    };

rezultat = false;
for nomer_shablona = 1:numel(shablony)
    if ~isempty(regexp(stroka, shablony{nomer_shablona}, 'once'))
        rezultat = true;
        return
    end
end
end

function rezultat = est_neskolko_zagolovkov_v_odnoi_stroke(stroka)
rezultat = ~isempty(regexp(stroka, '^#{1,6}\s+.*\s+#{1,6}\s+', 'once'));
end

function rezultat = est_neskolko_punktov_spiska_v_odnoi_stroke(stroka)
rezultat = ...
    ~isempty(regexp(stroka, '^\s*[-*+]\s+.+\s{2,}[-*+]\s+\S', 'once')) ...
    || ~isempty(regexp(stroka, '^\s*\d+\.\s+.+\s{2,}\d+\.\s+\S', 'once'));
end

function rezultat = razreshena_dlinnaya_stroka(stroka)
rezultat = ...
    contains(stroka, 'http://') || ...
    contains(stroka, 'https://') || ...
    ~isempty(regexp(stroka, '[A-Za-z]:\\', 'once')) || ...
    ~isempty(regexp(stroka, '(^|[\s(])/[^\s]+', 'once'));
end

function baity = prochitat_baity(put_k_failu)
identifikator = fopen(put_k_failu, 'rb');
if identifikator == -1
    error('%s', sprintf( ...
        'Не удалось открыть файл для проверки физического формата: %s', ...
        put_k_failu));
end

ochistka = onCleanup(@() fclose(identifikator));
baity = fread(identifikator, Inf, '*uint8');
clear ochistka
end

function vyzvat_oshibku_formata(put_k_failu, nomer_stroki, prichina)
error('%s', sprintf( ...
    'Нарушен физический формат файла %s. Строка: %d. Причина: %s', ...
    put_k_failu, nomer_stroki, prichina));
end
