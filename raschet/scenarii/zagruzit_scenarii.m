function scenarii = zagruzit_scenarii(put_k_failu)
if nargin < 1 || strlength(string(put_k_failu)) == 0
    error('%s', 'Не задан путь к файлу сценария.');
end

if ~isfile(put_k_failu)
    error('%s', sprintf('Не найден файл сценария: %s', put_k_failu));
end

try
    tekst_faila = fileread(put_k_failu);
catch oshibka_chteniya
    error('%s', sprintf( ...
        'Не удалось прочитать файл сценария %s. Причина: %s', ...
        put_k_failu, oshibka_chteniya.message));
end

try
    scenarii = jsondecode(tekst_faila);
catch oshibka_razbora
    error('%s', sprintf( ...
        'Не удалось разобрать JSON-сценарий %s. Причина: %s', ...
        put_k_failu, oshibka_razbora.message));
end

if ~isstruct(scenarii)
    error('%s', sprintf( ...
        'Файл сценария должен содержать объект JSON: %s', ...
        put_k_failu));
end
end
