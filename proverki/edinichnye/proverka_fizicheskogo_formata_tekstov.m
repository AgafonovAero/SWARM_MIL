function proverka_fizicheskogo_formata_tekstov(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Не задан корень проекта для проверки физического формата текстов.');
end

rasshireniya = {'.m', '.md', '.json'};
spisok_failov = poluchit_spisok_failov(koren_proekta, rasshireniya);

for nomer_faila = 1:numel(spisok_failov)
    put_k_failu = spisok_failov{nomer_faila};
    [~, ~, rasshirenie] = fileparts(put_k_failu);
    proverit_nepustoi_fail(put_k_failu);

    switch lower(rasshirenie)
        case '.m'
            proverit_matlab_fail(put_k_failu);
        case '.md'
            proverit_markdown_fail(put_k_failu);
        case '.json'
            proverit_json_fail(put_k_failu);
        otherwise
            error('%s', sprintf( ...
                'Обнаружено неподдерживаемое расширение файла при проверке формата: %s', ...
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
tekst = fileread(put_k_failu);

if strlength(string(tekst)) == 0 || strlength(strtrim(string(tekst))) == 0
    error('%s', sprintf( ...
        'Файл пустой или содержит только пробельные символы: %s', ...
        put_k_failu));
end
end

function proverit_matlab_fail(put_k_failu)
stroki = prochitat_stroki(put_k_failu);

for nomer_stroki = 1:numel(stroki)
    stroka = stroki{nomer_stroki};

    zapreshennaya_konstrukciya = ['^end' ' function$'];
    if ~isempty(regexp(strtrim(stroka), zapreshennaya_konstrukciya, 'once'))
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'в MATLAB-файле запрещена строка завершения функции в неверном виде');
    end

    if startsWith(strtrim(stroka), 'function ') ...
            && ~stroka_yavlyaetsya_korrektnym_obyavleniem_funkcii(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'объявление функции записано в неверном формате или объединено с телом функции');
    end

    if strlength(string(stroka)) > 180 && ~razreshena_dlinnaya_stroka_m(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'длина строки MATLAB превышает 180 символов');
    end
end
end

function proverit_markdown_fail(put_k_failu)
stroki = prochitat_stroki(put_k_failu);

for nomer_stroki = 1:numel(stroki)
    stroka = stroki{nomer_stroki};

    if isempty(stroka)
        continue
    end

    if est_neskolko_zagolovkov_v_odnoi_stroke(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'в строке Markdown обнаружено несколько заголовков');
    end

    if est_neskolko_punktov_spiska_v_odnoi_stroke(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'в строке Markdown обнаружено несколько пунктов списка');
    end

    if strlength(string(stroka)) > 240 && ~razreshena_dlinnaya_stroka_markdown(stroka)
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'длина строки Markdown превышает 240 символов');
    end
end
end

function proverit_json_fail(put_k_failu)
tekst = fileread(put_k_failu);
stroki = prochitat_stroki(put_k_failu);

for nomer_stroki = 1:numel(stroki)
    stroka = stroki{nomer_stroki};

    if strlength(string(stroka)) > 240
        vyzvat_oshibku_formata( ...
            put_k_failu, ...
            nomer_stroki, ...
            'длина строки JSON превышает 240 символов');
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

function stroki = prochitat_stroki(put_k_failu)
tekst = fileread(put_k_failu);
stroki = regexp(tekst, '\r\n|\n|\r', 'split');
end

function rezultat = stroka_yavlyaetsya_korrektnym_obyavleniem_funkcii(stroka)
stroka = strtrim(stroka);
shablony = {
    '^function\s+[A-Za-z]\w*\s*\(\s*[^)]*\s*\)\s*$'
    '^function\s+(?:\[[^\]]+\]|[A-Za-z]\w*)\s*=\s*[A-Za-z]\w*\s*\(\s*[^)]*\s*\)\s*$'
    '^function\s+(?:\[[^\]]+\]|[A-Za-z]\w*)\s*=\s*[A-Za-z]\w*\s*$'
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
shablon_nachala_spiska = '^\s*(?:[-*+]\s+|\d+\.\s+)';
shablon_vtorogo_punkta = '\s{2,}(?:[-*+]\s+|\d+\.\s+)';

rezultat = ...
    ~isempty(regexp(stroka, shablon_nachala_spiska, 'once')) && ...
    ~isempty(regexp(stroka, shablon_vtorogo_punkta, 'once'));
end

function rezultat = razreshena_dlinnaya_stroka_m(stroka)
rezultat = contains(stroka, 'http://') || contains(stroka, 'https://');
end

function rezultat = razreshena_dlinnaya_stroka_markdown(stroka)
rezultat = ...
    contains(stroka, 'http://') || ...
    contains(stroka, 'https://') || ...
    ~isempty(regexp(stroka, '[A-Za-z]:\\', 'once')) || ...
    ~isempty(regexp(stroka, '(^|[\s(])/[^\s]+', 'once'));
end

function vyzvat_oshibku_formata(put_k_failu, nomer_stroki, prichina)
error('%s', sprintf( ...
    'Нарушен физический формат текстового файла %s. Строка: %d. Причина: %s.', ...
    put_k_failu, nomer_stroki, prichina));
end
