function plan_serii = zagruzit_plan_serii_opytov(put_k_failu)
if nargin < 1 || strlength(string(put_k_failu)) == 0
    error('%s', 'Не задан путь к JSON-плану серии опытов.');
end

if ~isfile(put_k_failu)
    error('%s', sprintf( ...
        'Не найден файл плана серии опытов: %s', ...
        put_k_failu));
end

try
    tekst_faila = fileread(put_k_failu);
catch oshibka_chteniya
    error('%s', sprintf( ...
        'Не удалось прочитать файл плана серии %s. Причина: %s', ...
        put_k_failu, ...
        oshibka_chteniya.message));
end

try
    plan_serii = jsondecode(tekst_faila);
catch oshibka_razbora
    error('%s', sprintf( ...
        'Не удалось разобрать JSON-план серии %s. Причина: %s', ...
        put_k_failu, ...
        oshibka_razbora.message));
end

if ~isstruct(plan_serii)
    error('%s', sprintf( ...
        'Файл плана серии должен содержать JSON-объект: %s', ...
        put_k_failu));
end

plan_serii = proverit_plan_serii_opytov(plan_serii);
end
