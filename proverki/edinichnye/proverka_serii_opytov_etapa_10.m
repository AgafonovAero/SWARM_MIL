function proverka_serii_opytov_etapa_10(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для проверки серий опытов этапа 10 требуется корень проекта.');
end

put_k_planu = fullfile( ...
    koren_proekta, ...
    'opyty', 'serii', 'malaya_seriya_stroi_i_svyaz.json');
plan_serii = zagruzit_plan_serii_opytov(put_k_planu);
varianty = sozdat_varianty_serii_opytov(plan_serii);

if numel(varianty) < 2
    error('%s', ...
        'Малая серия этапа 10 должна содержать не меньше двух вариантов.');
end

rezultat_serii = vypolnit_seriyu_opytov(koren_proekta, plan_serii);
ochistka_rezultatov = onCleanup(@() ochistit_rezultaty(rezultat_serii));

proverit_rezultaty_variantov(rezultat_serii.rezultaty_opytov);
proverit_sohranennye_faily(rezultat_serii.papka_rezultatov);

grafiki = postroit_grafiki_serii_opytov( ...
    rezultat_serii, ...
    false, ...
    rezultat_serii.papka_rezultatov);
ochistka_figur = onCleanup(@() zakryt_figury(grafiki.figury));

if ~all(isgraphics(grafiki.figury))
    error('%s', ...
        'Графики серии этапа 10 должны возвращать корректные дескрипторы фигур.');
end

if isempty(grafiki.puti_k_failam) || ~all(cellfun(@isfile, grafiki.puti_k_failam))
    error('%s', ...
        'Графики серии этапа 10 должны сохраняться в файлы PNG.');
end

clear ochistka_figur
zakryt_figury(grafiki.figury);
clear ochistka_rezultatov
ochistit_rezultaty(rezultat_serii);

soobshchenie('Серии опытов этапа 10 проверены успешно');
end

function proverit_rezultaty_variantov(rezultaty_opytov)
if ~isstruct(rezultaty_opytov) || isempty(rezultaty_opytov)
    error('%s', 'Серия этапа 10 должна содержать непустой список результатов.');
end

for nomer_opyta = 1:numel(rezultaty_opytov)
    rezultat = rezultaty_opytov(nomer_opyta);
    if ~isfield(rezultat, 'pokazateli') || ~isstruct(rezultat.pokazateli)
        error('%s', sprintf( ...
            'В результате варианта %d отсутствуют показатели опыта.', ...
            nomer_opyta));
    end

    chisla = struct2cell(udalit_strokovye_polya(rezultat.pokazateli));
    chisla = cell2mat(chisla(:));
    if any(~isfinite(chisla))
        error('%s', sprintf( ...
            'Показатели варианта %d должны быть конечными.', ...
            nomer_opyta));
    end

    doli = [ ...
        rezultat.pokazateli.dolya_vremeni_svyaznogo_roya
        rezultat.pokazateli.srednyaya_dolya_odinochnyh_zvenev
        rezultat.pokazateli.dolya_dostavlennyh_soobshchenii
        ];
    if any(doli < 0) || any(doli > 1)
        error('%s', sprintf( ...
            'Долевые показатели варианта %d должны быть в диапазоне от 0 до 1.', ...
            nomer_opyta));
    end
end
end

function pokazateli = udalit_strokovye_polya(pokazateli)
pokazateli = rmfield(pokazateli, {'id_serii', 'id_varianta', 'id_scenariya'});
end

function proverit_sohranennye_faily(papka_rezultatov)
if strlength(string(papka_rezultatov)) == 0 || ~isfolder(papka_rezultatov)
    error('%s', 'Папка результатов серии этапа 10 не создана.');
end

obyazatelnye_faily = {
    'summary.md'
    'metrics.json'
    'result.mat'
    };

for nomer_faila = 1:numel(obyazatelnye_faily)
    put_k_failu = fullfile(papka_rezultatov, obyazatelnye_faily{nomer_faila});
    if ~isfile(put_k_failu)
        error('%s', sprintf( ...
            'Не найден сохраненный файл серии: %s', ...
            put_k_failu));
    end
end
end

function zakryt_figury(figury)
for nomer_figury = 1:numel(figury)
    if isgraphics(figury(nomer_figury))
        close(figury(nomer_figury));
    end
end
end

function ochistit_rezultaty(rezultat_serii)
if ~isstruct(rezultat_serii) || ~isfield(rezultat_serii, 'papka_rezultatov')
    return
end

papka_rezultatov = rezultat_serii.papka_rezultatov;
if strlength(string(papka_rezultatov)) == 0 || ~isfolder(papka_rezultatov)
    return
end

try
    rmdir(papka_rezultatov, 's');
catch
end
end
