function proverka_resursov_etapa_11(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для проверки ресурсов этапа 11 требуется корень проекта.');
end

put_k_planu = fullfile( ...
    koren_proekta, ...
    'opyty', 'serii', 'malaya_seriya_stroi_i_svyaz.json');
plan_serii = zagruzit_plan_serii_opytov(put_k_planu);
rezultat_serii = vypolnit_seriyu_opytov(koren_proekta, plan_serii);
ochistka_rezultatov = onCleanup(@() ochistit_papku(rezultat_serii.papka_rezultatov));

parametry_resursov = parametry_resursov_po_umolchaniyu();
rezultat_resursov_opyta = raschet_resursov_po_opytu( ...
    rezultat_serii.rezultaty_opytov(1), ...
    parametry_resursov);
rezultat_resursov_serii = raschet_resursov_po_serii( ...
    rezultat_serii, ...
    parametry_resursov);

proverit_rezultat_resursov_opyta(rezultat_resursov_opyta);
proverit_rezultat_resursov_serii(rezultat_resursov_serii);

rezultat_serii_s_resursami = rezultat_serii;
rezultat_serii_s_resursami.resursnaya_svodka = rezultat_resursov_serii;
papka_resursov = sohranit_rezultaty_serii( ...
    koren_proekta, ...
    rezultat_serii_s_resursami);
ochistka_papki_resursov = onCleanup(@() ochistit_papku(papka_resursov));

grafiki = postroit_grafiki_resursov( ...
    rezultat_resursov_opyta, ...
    rezultat_resursov_serii, ...
    false, ...
    papka_resursov);
ochistka_figur = onCleanup(@() zakryt_figury(grafiki.figury));

if ~all(isgraphics(grafiki.figury))
    error('%s', ...
        'Графики ресурсов этапа 11 должны возвращать корректные дескрипторы фигур.');
end

if isempty(grafiki.puti_k_failam) || ~all(cellfun(@isfile, grafiki.puti_k_failam))
    error('%s', ...
        'Графики ресурсов этапа 11 должны сохраняться в файлы PNG.');
end

rezultat_serii_s_resursami.puti_k_grafikam_resursov = grafiki.puti_k_failam;
rezultat_serii_s_resursami.papka_rezultatov = papka_resursov;
sohranit_rezultaty_serii(koren_proekta, rezultat_serii_s_resursami);

if ~isfile(fullfile(papka_resursov, 'resources.json'))
    error('%s', ...
        'После сохранения ресурсной сводки должен создаваться файл resources.json.');
end

clear ochistka_figur
zakryt_figury(grafiki.figury);
clear ochistka_papki_resursov
ochistit_papku(papka_resursov);
clear ochistka_rezultatov
ochistit_papku(rezultat_serii.papka_rezultatov);

soobshchenie('Ресурсы этапа 11 проверены успешно');
end

function proverit_rezultat_resursov_opyta(rezultat_resursov_opyta)
if any(~isfinite(rezultat_resursov_opyta.energiya_po_vremeni), 'all')
    error('%s', ...
        'Остатки энергии в результате одного опыта должны быть конечными.');
end

rashody = [ ...
    rezultat_resursov_opyta.rashod_energii_dvizhenie
    rezultat_resursov_opyta.rashod_energii_peredacha
    rezultat_resursov_opyta.rashod_energii_priem
    rezultat_resursov_opyta.rashod_energii_obrabotka
    ];
if any(rashody < 0, 'all')
    error('%s', ...
        'Расход энергии в результате одного опыта не должен быть отрицательным.');
end

dolya = rezultat_resursov_opyta.dolya_bvs_s_dostatochnoi_energiey;
if ~isfinite(dolya) || dolya < 0 || dolya > 1
    error('%s', ...
        'Доля БВС с достаточной энергией должна быть в диапазоне от 0 до 1.');
end

nagruzka_golovnyh = rezultat_resursov_opyta.nagruzka_golovnyh_bvs.otnositelnaya_nagruzka_golovnogo_bvs;
if any(~isfinite(nagruzka_golovnyh)) || any(nagruzka_golovnyh < 0)
    error('%s', ...
        'Нагрузки головных БВС должны быть конечными неотрицательными числами.');
end
end

function proverit_rezultat_resursov_serii(rezultat_resursov_serii)
if ~istable(rezultat_resursov_serii.tablica_resursov) ...
        || height(rezultat_resursov_serii.tablica_resursov) == 0
    error('%s', ...
        'Ресурсная сводка серии должна содержать непустую таблицу.');
end

chisla = table2array(removevars( ...
    rezultat_resursov_serii.tablica_resursov, ...
    {'id_varianta', 'id_scenariya'}));
if any(~isfinite(chisla), 'all')
    error('%s', ...
        'Таблица ресурсов серии должна содержать только конечные значения.');
end
end

function zakryt_figury(figury)
for nomer_figury = 1:numel(figury)
    if isgraphics(figury(nomer_figury))
        close(figury(nomer_figury));
    end
end
end

function ochistit_papku(papka)
if strlength(string(papka)) == 0 || ~isfolder(papka)
    return
end

try
    rmdir(papka, 's');
catch
end
end
