function proverka_resursnoi_dopustimosti_etapa_12(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', [ ...
        'Для проверки ресурсной допустимости этапа 12 требуется корень ' ...
        'проекта.' ...
        ]);
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

proverit_dopustimost_opyta(rezultat_resursov_opyta.dopustimost_resursov);
proverit_dopustimost_serii(rezultat_resursov_serii);

zhestkie_parametry = sozdat_zhestkie_parametry( ...
    parametry_resursov, ...
    rezultat_resursov_opyta);
zhestkaya_dopustimost_opyta = otsenit_dopustimost_resursov_opyta( ...
    rezultat_resursov_opyta, ...
    zhestkie_parametry);
if zhestkaya_dopustimost_opyta.itog_dopustim
    error('%s', [ ...
        'Жесткие пороги ресурсной допустимости должны давать хотя бы одно ' ...
        'нарушение для одного опыта.' ...
        ]);
end

zhestkaya_dopustimost_serii = otsenit_dopustimost_resursov_serii( ...
    rezultat_resursov_serii, ...
    zhestkie_parametry);
if zhestkaya_dopustimost_serii.chislo_nedopustimyh_variantov < 1
    error('%s', [ ...
        'Жесткие пороги ресурсной допустимости должны давать хотя бы ' ...
        'один недопустимый вариант серии.' ...
        ]);
end

papka_resursov = sohranit_rezultaty_serii( ...
    koren_proekta, ...
    dobavit_resursy_v_rezultat_serii(rezultat_serii, rezultat_resursov_serii));
ochistka_papki_resursov = onCleanup(@() ochistit_papku(papka_resursov));

grafiki = postroit_grafiki_resursov( ...
    rezultat_resursov_opyta, ...
    rezultat_resursov_serii, ...
    false, ...
    papka_resursov);
ochistka_figur = onCleanup(@() zakryt_figury(grafiki.figury));

if ~all(isgraphics(grafiki.figury))
    error('%s', [ ...
        'Графики ресурсов этапа 12 должны возвращать корректные ' ...
        'дескрипторы фигур.' ...
        ]);
end

clear ochistka_figur
zakryt_figury(grafiki.figury);
clear ochistka_papki_resursov
ochistit_papku(papka_resursov);
clear ochistka_rezultatov
ochistit_papku(rezultat_serii.papka_rezultatov);

soobshchenie('Ресурсная допустимость этапа 12 проверена успешно');
end

function proverit_dopustimost_opyta(dopustimost)
obyazatelnye_polya = {
    'itog_dopustim'
    'energia_dopustima'
    'vychislitelnaya_nagruzka_dopustima'
    'ocheredi_dopustimy'
    'nagruzka_golovnogo_bvs_dopustima'
    'nagruzka_svyazi_dopustima'
    'narusheniya'
    'opisanie_narushenii'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(dopustimost, imya_polya)
        error('%s', sprintf( ...
            'В структуре допустимости опыта отсутствует поле %s.', ...
            imya_polya));
    end
end

proverit_priznaki_dopustimosti( ...
    dopustimost.itog_dopustim, ...
    dopustimost.energia_dopustima, ...
    dopustimost.vychislitelnaya_nagruzka_dopustima, ...
    dopustimost.ocheredi_dopustimy, ...
    dopustimost.nagruzka_golovnogo_bvs_dopustima, ...
    dopustimost.nagruzka_svyazi_dopustima);

if ~iscell(dopustimost.narusheniya)
    error('%s', ...
        'Список нарушений ресурсной допустимости должен быть ячейковым массивом.');
end

if ~(ischar(dopustimost.opisanie_narushenii) ...
        || (isstring(dopustimost.opisanie_narushenii) ...
        && isscalar(dopustimost.opisanie_narushenii)))
    error('%s', ...
        'Описание нарушений ресурсной допустимости должно быть строкой.');
end
end

function proverit_dopustimost_serii(rezultat_resursov_serii)
obyazatelnye_polya = {
    'tablica_resursov'
    'dopustimost_po_variantam'
    'opisaniya_narushenii_po_variantam'
    'chislo_dopustimyh_variantov'
    'chislo_nedopustimyh_variantov'
    'osnovnye_prichiny_narushenii'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_resursov_serii, imya_polya)
        error('%s', sprintf( ...
            'В ресурcной сводке серии отсутствует поле %s.', ...
            imya_polya));
    end
end

tablica = rezultat_resursov_serii.tablica_resursov;
obyazatelnye_stolbcy = {
    'itog_dopustim'
    'energia_dopustima'
    'vychislitelnaya_nagruzka_dopustima'
    'ocheredi_dopustimy'
    'nagruzka_golovnogo_bvs_dopustima'
    'nagruzka_svyazi_dopustima'
    'chislo_narushenii'
    };

for nomer_stolbca = 1:numel(obyazatelnye_stolbcy)
    imya_stolbca = obyazatelnye_stolbcy{nomer_stolbca};
    if ~ismember(imya_stolbca, tablica.Properties.VariableNames)
        error('%s', sprintf( ...
            'В таблице ресурсов серии отсутствует столбец %s.', ...
            imya_stolbca));
    end
end

proverit_priznaki_dopustimosti(tablica.itog_dopustim);
proverit_priznaki_dopustimosti(tablica.energia_dopustima);
proverit_priznaki_dopustimosti(tablica.vychislitelnaya_nagruzka_dopustima);
proverit_priznaki_dopustimosti(tablica.ocheredi_dopustimy);
proverit_priznaki_dopustimosti(tablica.nagruzka_golovnogo_bvs_dopustima);
proverit_priznaki_dopustimosti(tablica.nagruzka_svyazi_dopustima);

if any(tablica.chislo_narushenii < 0) || any(mod(tablica.chislo_narushenii, 1) ~= 0)
    error('%s', ...
        'Число нарушений в таблице ресурсов серии должно быть целым неотрицательным.');
end

if rezultat_resursov_serii.chislo_dopustimyh_variantov ...
        + rezultat_resursov_serii.chislo_nedopustimyh_variantov ...
        ~= height(tablica)
    error('%s', [ ...
        'Число допустимых и недопустимых вариантов должно совпадать ' ...
        'с числом строк таблицы ресурсов.' ...
        ]);
end
end

function proverit_priznaki_dopustimosti(varargin)
for nomer_argumenta = 1:nargin
    znacheniya = varargin{nomer_argumenta};
    if islogical(znacheniya)
        continue
    end

    if ~isnumeric(znacheniya) || any(~ismember(znacheniya(:), [0 1]))
        error('%s', [ ...
            'Признаки допустимости должны быть логическими значениями ' ...
            'или строго 0/1.' ...
            ]);
    end
end
end

function zhestkie_parametry = sozdat_zhestkie_parametry(parametry_resursov, rezultat_resursov_opyta)
zhestkie_parametry = parametry_resursov;
minimalnyi_ostatok = min(rezultat_resursov_opyta.energiya_ostatok_itog);

if minimalnyi_ostatok < zhestkie_parametry.energiya_start_dzh
    zhestkie_parametry.minimalnyi_dopustimyi_ostatok_energii_dzh = ...
        (minimalnyi_ostatok + zhestkie_parametry.energiya_start_dzh) / 2;
else
    zhestkie_parametry.maksimalnaya_maksimalnaya_vychislitelnaya_nagruzka = 0;
end
end

function rezultat_serii_s_resursami = dobavit_resursy_v_rezultat_serii(rezultat_serii, rezultat_resursov_serii)
rezultat_serii_s_resursami = rezultat_serii;
rezultat_serii_s_resursami.resursnaya_svodka = rezultat_resursov_serii;
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
