function rezultat = proverit_scenarii(scenarii, put_k_failu)
if nargin < 1 || ~isstruct(scenarii)
    error('%s', 'Для проверки сценария требуется структура MATLAB.');
end

if nargin < 2 || strlength(string(put_k_failu)) == 0
    put_k_failu = 'без указания файла';
end

obyazatelnye_verhnie_polya = {
    'id_scenariya'
    'nazvanie'
    'opisanie'
    'nachalnoe_chislo'
    'vremya_modelirovaniya'
    'shag_modelirovaniya'
    'oblast_poleta'
    'sostav_roya'
    'tseli_zadaniya'
    'prepyatstviya'
    'zony_zapreta'
    'otkazy'
    'pomekhi_svyazi'
    'ogranicheniya_bezopasnosti'
    'ozhidaemye_pokazateli'
    };

proverit_verhnie_polya(scenarii, obyazatelnye_verhnie_polya, put_k_failu);
proverit_strokovoe_pole(scenarii, 'id_scenariya', put_k_failu);
proverit_strokovoe_pole(scenarii, 'nazvanie', put_k_failu);
proverit_strokovoe_pole(scenarii, 'opisanie', put_k_failu);
proverit_celoe_chislo(scenarii.nachalnoe_chislo, ...
    'nachalnoe_chislo', put_k_failu, true);
proverit_polozhitelnoe_chislo(scenarii.vremya_modelirovaniya, ...
    'vremya_modelirovaniya', put_k_failu);
proverit_polozhitelnoe_chislo(scenarii.shag_modelirovaniya, ...
    'shag_modelirovaniya', put_k_failu);

if scenarii.shag_modelirovaniya >= scenarii.vremya_modelirovaniya
    error('%s', sprintf( ...
        'Шаг моделирования должен быть меньше времени моделирования в сценарии %s.', ...
        put_k_failu));
end

proverit_sootvetstvie_identifikatora_imeni_faila( ...
    scenarii.id_scenariya, put_k_failu);
proverit_razmer_bazovogo_scenariya( ...
    scenarii.id_scenariya, scenarii.sostav_roya, put_k_failu);

oblast_poleta = proverit_oblast_poleta( ...
    scenarii.oblast_poleta, put_k_failu, 'oblast_poleta');
identifikatory_bvs = proverit_sostav_roya( ...
    scenarii.sostav_roya, oblast_poleta, put_k_failu);
proverit_tseli_zadaniya(scenarii.tseli_zadaniya, oblast_poleta, put_k_failu);
proverit_obekty_v_oblasti(scenarii.prepyatstviya, oblast_poleta, ...
    put_k_failu, 'prepyatstviya', 'id_prepyatstviya');
proverit_obekty_v_oblasti(scenarii.zony_zapreta, oblast_poleta, ...
    put_k_failu, 'zony_zapreta', 'id_zony');
proverit_otkazy(scenarii.otkazy, identifikatory_bvs, ...
    scenarii.vremya_modelirovaniya, put_k_failu);
proverit_pomekhi_svyazi(scenarii.pomekhi_svyazi, oblast_poleta, ...
    scenarii.vremya_modelirovaniya, put_k_failu);
zashchitnye_ogranicheniya_proideny = proverit_ogranicheniya_bezopasnosti( ...
    scenarii.ogranicheniya_bezopasnosti, put_k_failu);
proverit_ozhidaemye_pokazateli(scenarii.ozhidaemye_pokazateli, put_k_failu);
proverit_otsutstvie_zapreshchennogo_soderzhaniya(scenarii, put_k_failu);

rezultat = struct();
rezultat.id_scenariya = char(string(scenarii.id_scenariya));
rezultat.kolichestvo_bvs = numel(identifikatory_bvs);
rezultat.zashchitnye_ogranicheniya_proideny = zashchitnye_ogranicheniya_proideny;
end

function proverit_verhnie_polya(scenarii, obyazatelnye_polya, put_k_failu)
imena_polei = fieldnames(scenarii);
otsutstvuyushchie_polya = setdiff(obyazatelnye_polya, imena_polei);
lishnie_polya = setdiff(imena_polei, obyazatelnye_polya);

if ~isempty(otsutstvuyushchie_polya)
    error('%s', sprintf( ...
        'В сценарии %s отсутствует обязательное поле: %s', ...
        put_k_failu, otsutstvuyushchie_polya{1}));
end

if ~isempty(lishnie_polya)
    error('%s', sprintf( ...
        'В сценарии %s обнаружено лишнее верхнеуровневое поле: %s', ...
        put_k_failu, lishnie_polya{1}));
end
end

function proverit_sootvetstvie_identifikatora_imeni_faila(id_scenariya, put_k_failu)
if ~isfile(put_k_failu)
    return
end

[~, imya_faila_bez_rasshireniya, ~] = fileparts(put_k_failu);
if ~strcmp(char(string(id_scenariya)), imya_faila_bez_rasshireniya)
    error('%s', sprintf( ...
        'Идентификатор сценария %s не совпадает с именем файла %s.', ...
        char(string(id_scenariya)), imya_faila_bez_rasshireniya));
end
end

function proverit_razmer_bazovogo_scenariya(id_scenariya, sostav_roya, put_k_failu)
ozhidaemoe_kolichestvo_bvs = poluchit_ozhidaemoe_kolichestvo_bvs( ...
    char(string(id_scenariya)));
if isempty(ozhidaemoe_kolichestvo_bvs)
    return
end

zapisi_bvs = normalizovat_massiv_zapisei(sostav_roya, 'sostav_roya', put_k_failu, false);
if numel(zapisi_bvs) ~= ozhidaemoe_kolichestvo_bvs
    error('%s', sprintf( ...
        'Для сценария %s ожидается %d БВС, обнаружено %d.', ...
        char(string(id_scenariya)), ...
        ozhidaemoe_kolichestvo_bvs, ...
        numel(zapisi_bvs)));
end
end

function ozhidaemoe_kolichestvo_bvs = poluchit_ozhidaemoe_kolichestvo_bvs(id_scenariya)
switch id_scenariya
    case 'stroi_malyi'
        ozhidaemoe_kolichestvo_bvs = 5;
    case {'pokrytie_oblasti', 'otkaz_uchastnika', 'pomekha_svyazi'}
        ozhidaemoe_kolichestvo_bvs = 10;
    case 'poisk_tseli'
        ozhidaemoe_kolichestvo_bvs = 8;
    otherwise
        ozhidaemoe_kolichestvo_bvs = [];
end
end

function oblast_poleta = proverit_oblast_poleta(oblast_poleta, put_k_failu, imya_polya)
if ~isstruct(oblast_poleta)
    error('%s', sprintf( ...
        'Поле %s в сценарии %s должно быть объектом.', ...
        imya_polya, put_k_failu));
end

imena_granits = {'xmin', 'xmax', 'ymin', 'ymax', 'zmin', 'zmax'};
for nomer_granitsy = 1:numel(imena_granits)
    imya_granitsy = imena_granits{nomer_granitsy};
    if ~isfield(oblast_poleta, imya_granitsy)
        error('%s', sprintf( ...
            'В объекте %s сценария %s отсутствует поле %s.', ...
            imya_polya, put_k_failu, imya_granitsy));
    end

    proverit_chislo( ...
        oblast_poleta.(imya_granitsy), imya_granitsy, put_k_failu, true, true);
end

if ~(oblast_poleta.xmin < oblast_poleta.xmax ...
        && oblast_poleta.ymin < oblast_poleta.ymax ...
        && oblast_poleta.zmin < oblast_poleta.zmax)
    error('%s', sprintf( ...
        'Границы области полета заданы некорректно в сценарии %s.', ...
        put_k_failu));
end
end

function identifikatory_bvs = proverit_sostav_roya(sostav_roya, oblast_poleta, put_k_failu)
zapisi_bvs = normalizovat_massiv_zapisei(sostav_roya, 'sostav_roya', put_k_failu, false);
identifikatory_bvs = cell(1, numel(zapisi_bvs));

for nomer_bvs = 1:numel(zapisi_bvs)
    tekushchii_bvs = zapisi_bvs{nomer_bvs};
    proverit_nalichie_polei(tekushchii_bvs, ...
        {'id_bvs', 'rol', 'nachalnoe_polozhenie', 'nachalnaya_skorost', 'zapas_energii'}, ...
        'БВС', put_k_failu);
    proverit_strokovoe_pole(tekushchii_bvs, 'id_bvs', put_k_failu);
    proverit_strokovoe_pole(tekushchii_bvs, 'rol', put_k_failu);
    proverit_vektor_iz_treh_komponent( ...
        tekushchii_bvs.nachalnoe_polozhenie, 'nachalnoe_polozhenie', put_k_failu);
    proverit_vektor_iz_treh_komponent( ...
        tekushchii_bvs.nachalnaya_skorost, 'nachalnaya_skorost', put_k_failu);
    proverit_chislo(tekushchii_bvs.zapas_energii, 'zapas_energii', put_k_failu, true, true);

    if ~tochka_v_oblasti(tekushchii_bvs.nachalnoe_polozhenie, oblast_poleta)
        error('%s', sprintf( ...
            'Начальное положение БВС %s находится вне области полета в сценарии %s.', ...
            tekushchii_bvs.id_bvs, put_k_failu));
    end

    identifikatory_bvs{nomer_bvs} = char(string(tekushchii_bvs.id_bvs));
end

if numel(unique(identifikatory_bvs)) ~= numel(identifikatory_bvs)
    error('%s', sprintf( ...
        'В сценарии %s обнаружены неуникальные идентификаторы БВС.', ...
        put_k_failu));
end
end

function proverit_tseli_zadaniya(tseli_zadaniya, oblast_poleta, put_k_failu)
zapisi_tselei = normalizovat_massiv_zapisei(tseli_zadaniya, 'tseli_zadaniya', put_k_failu, false);

for nomer_tseli = 1:numel(zapisi_tselei)
    tekushchaya_tsel = zapisi_tselei{nomer_tseli};
    proverit_nalichie_polei(tekushchaya_tsel, ...
        {'id_tseli', 'tip', 'opisanie', 'kriterii'}, ...
        'цели задания', put_k_failu);
    proverit_strokovoe_pole(tekushchaya_tsel, 'id_tseli', put_k_failu);
    proverit_strokovoe_pole(tekushchaya_tsel, 'tip', put_k_failu);
    proverit_strokovoe_pole(tekushchaya_tsel, 'opisanie', put_k_failu);
    proverit_strokovoe_pole(tekushchaya_tsel, 'kriterii', put_k_failu);

    if isfield(tekushchaya_tsel, 'granitsy')
        proverit_granitsy_v_oblasti(tekushchaya_tsel.granitsy, oblast_poleta, ...
            put_k_failu, 'granitsy цели задания');
    end
end
end

function proverit_obekty_v_oblasti(massiv_obektov, oblast_poleta, put_k_failu, imya_polya, kluchevoe_pole)
zapisi = normalizovat_massiv_zapisei(massiv_obektov, imya_polya, put_k_failu, true);

for nomer_zapisi = 1:numel(zapisi)
    tekushchaya_zapis = zapisi{nomer_zapisi};
    proverit_nalichie_polei(tekushchaya_zapis, {kluchevoe_pole, 'granitsy'}, imya_polya, put_k_failu);
    proverit_strokovoe_pole(tekushchaya_zapis, kluchevoe_pole, put_k_failu);
    proverit_granitsy_v_oblasti(tekushchaya_zapis.granitsy, oblast_poleta, ...
        put_k_failu, imya_polya);
end
end

function proverit_otkazy(otkazy, identifikatory_bvs, vremya_modelirovaniya, put_k_failu)
zapisi_otkazov = normalizovat_massiv_zapisei(otkazy, 'otkazy', put_k_failu, true);

for nomer_otkaza = 1:numel(zapisi_otkazov)
    tekushchii_otkaz = zapisi_otkazov{nomer_otkaza};
    proverit_nalichie_polei(tekushchii_otkaz, ...
        {'id_sobytiya', 'id_bvs', 'tip', 'vremya_sobytiya', 'opisanie'}, ...
        'отказа', put_k_failu);
    proverit_strokovoe_pole(tekushchii_otkaz, 'id_sobytiya', put_k_failu);
    proverit_strokovoe_pole(tekushchii_otkaz, 'id_bvs', put_k_failu);
    proverit_strokovoe_pole(tekushchii_otkaz, 'tip', put_k_failu);
    proverit_strokovoe_pole(tekushchii_otkaz, 'opisanie', put_k_failu);
    proverit_chislo( ...
        tekushchii_otkaz.vremya_sobytiya, 'vremya_sobytiya', put_k_failu, true, true);

    if tekushchii_otkaz.vremya_sobytiya > vremya_modelirovaniya
        error('%s', sprintf( ...
            'Событие отказа выходит за время моделирования в сценарии %s.', ...
            put_k_failu));
    end

    if ~ismember(char(string(tekushchii_otkaz.id_bvs)), identifikatory_bvs)
        error('%s', sprintf( ...
            'Событие отказа ссылается на неизвестный БВС в сценарии %s.', ...
            put_k_failu));
    end
end
end

function proverit_pomekhi_svyazi(pomekhi_svyazi, oblast_poleta, vremya_modelirovaniya, put_k_failu)
zapisi_pomeh = normalizovat_massiv_zapisei(pomekhi_svyazi, 'pomekhi_svyazi', put_k_failu, true);

for nomer_pomehi = 1:numel(zapisi_pomeh)
    tekushchaya_pomeha = zapisi_pomeh{nomer_pomehi};
    proverit_nalichie_polei(tekushchaya_pomeha, ...
        {'id_sobytiya', 'opisanie', 'vremya_nachala', 'vremya_okonchaniya', ...
        'koefficient_uhudsheniya', 'oblast_deistviya'}, ...
        'помехи связи', put_k_failu);
    proverit_strokovoe_pole(tekushchaya_pomeha, 'id_sobytiya', put_k_failu);
    proverit_strokovoe_pole(tekushchaya_pomeha, 'opisanie', put_k_failu);
    proverit_chislo( ...
        tekushchaya_pomeha.vremya_nachala, 'vremya_nachala', put_k_failu, true, true);
    proverit_chislo( ...
        tekushchaya_pomeha.vremya_okonchaniya, 'vremya_okonchaniya', put_k_failu, true, true);
    proverit_chislo( ...
        tekushchaya_pomeha.koefficient_uhudsheniya, 'koefficient_uhudsheniya', put_k_failu, true, true);
    proverit_granitsy_v_oblasti(tekushchaya_pomeha.oblast_deistviya, oblast_poleta, ...
        put_k_failu, 'oblast_deistviya помехи связи');

    if tekushchaya_pomeha.vremya_nachala >= tekushchaya_pomeha.vremya_okonchaniya
        error('%s', sprintf( ...
            'Временные границы помехи связи заданы некорректно в сценарии %s.', ...
            put_k_failu));
    end

    if tekushchaya_pomeha.vremya_okonchaniya > vremya_modelirovaniya
        error('%s', sprintf( ...
            'Помеха связи выходит за пределы времени моделирования в сценарии %s.', ...
            put_k_failu));
    end

    if tekushchaya_pomeha.koefficient_uhudsheniya > 1
        error('%s', sprintf( ...
            'Коэффициент ухудшения помехи связи должен быть не больше 1 в сценарии %s.', ...
            put_k_failu));
    end
end
end

function rezultat = proverit_ogranicheniya_bezopasnosti(ogranicheniya_bezopasnosti, put_k_failu)
if ~isstruct(ogranicheniya_bezopasnosti)
    error('%s', sprintf( ...
        'Поле ogranicheniya_bezopasnosti должно быть объектом в сценарии %s.', ...
        put_k_failu));
end

obyazatelnye_priznaki = {
    'issledovatelskii_harakter'
    'net_realnogo_upravleniya'
    'net_vrednogo_naznacheniya'
    };

for nomer_priznaka = 1:numel(obyazatelnye_priznaki)
    imya_priznaka = obyazatelnye_priznaki{nomer_priznaka};
    if ~isfield(ogranicheniya_bezopasnosti, imya_priznaka)
        error('%s', sprintf( ...
            'В ограничениях безопасности сценария %s отсутствует признак %s.', ...
            put_k_failu, imya_priznaka));
    end

    znachenie_priznaka = ogranicheniya_bezopasnosti.(imya_priznaka);
    if ~(isscalar(znachenie_priznaka) && (islogical(znachenie_priznaka) || isnumeric(znachenie_priznaka)))
        error('%s', sprintf( ...
            'Признак %s в ограничениях безопасности сценария %s должен быть логическим значением.', ...
            imya_priznaka, put_k_failu));
    end

    if ~logical(znachenie_priznaka)
        error('%s', sprintf( ...
            'Признак %s в ограничениях безопасности сценария %s должен быть равен true.', ...
            imya_priznaka, put_k_failu));
    end
end

rezultat = true;
end

function proverit_ozhidaemye_pokazateli(ozhidaemye_pokazateli, put_k_failu)
zapisi_pokazatelei = normalizovat_massiv_zapisei( ...
    ozhidaemye_pokazateli, 'ozhidaemye_pokazateli', put_k_failu, false);

for nomer_pokazatelya = 1:numel(zapisi_pokazatelei)
    tekushchii_pokazatel = zapisi_pokazatelei{nomer_pokazatelya};
    proverit_nalichie_polei(tekushchii_pokazatel, ...
        {'id_pokazatelya', 'opisanie'}, ...
        'ожидаемого показателя', put_k_failu);
    proverit_strokovoe_pole(tekushchii_pokazatel, 'id_pokazatelya', put_k_failu);
    proverit_strokovoe_pole(tekushchii_pokazatel, 'opisanie', put_k_failu);
end
end

function proverit_otsutstvie_zapreshchennogo_soderzhaniya(scenarii, put_k_failu)
zapreshchennye_fragmenty_polei = {
    'boev'
    'porazhen'
    'naveden'
    'lyud'
    'obhod'
    'zashchit'
    'podavlen'
    'radioelektronn'
    'prichinenie_vreda'
    };

zapreshchennye_fragmenty_teksta = {
    'боевое применение'
    'боевого применения'
    'цель поражения'
    'цели поражения'
    'наведение на людей'
    'наведения на людей'
    'обход средств защиты'
    'подавление связи'
    'радиоэлектронного воздействия'
    'причинение вреда'
    'причинения вреда'
    };

proyti_po_soderzhaniyu( ...
    scenarii, put_k_failu, zapreshchennye_fragmenty_polei, zapreshchennye_fragmenty_teksta);
end

function proyti_po_soderzhaniyu(zapis, put_k_failu, zapreshchennye_fragmenty_polei, zapreshchennye_fragmenty_teksta)
if isstruct(zapis)
    if numel(zapis) > 1
        for nomer_zapisi = 1:numel(zapis)
            proyti_po_soderzhaniyu( ...
                zapis(nomer_zapisi), put_k_failu, ...
                zapreshchennye_fragmenty_polei, zapreshchennye_fragmenty_teksta);
        end
        return
    end

    imena_polei = fieldnames(zapis);
    for nomer_polya = 1:numel(imena_polei)
        imya_polya = lower(imena_polei{nomer_polya});
        proverit_tekst_na_zapreshchennye_fragmenty( ...
            imya_polya, put_k_failu, zapreshchennye_fragmenty_polei, 'имя поля');
        proyti_po_soderzhaniyu( ...
            zapis.(imena_polei{nomer_polya}), put_k_failu, ...
            zapreshchennye_fragmenty_polei, zapreshchennye_fragmenty_teksta);
    end
elseif iscell(zapis)
    for nomer_elementa = 1:numel(zapis)
        proyti_po_soderzhaniyu( ...
            zapis{nomer_elementa}, put_k_failu, ...
            zapreshchennye_fragmenty_polei, zapreshchennye_fragmenty_teksta);
    end
elseif ischar(zapis) || (isstring(zapis) && isscalar(zapis))
    proverit_tekst_na_zapreshchennye_fragmenty( ...
        lower(char(string(zapis))), put_k_failu, ...
        zapreshchennye_fragmenty_teksta, 'текстовое значение');
end
end

function proverit_tekst_na_zapreshchennye_fragmenty(tekst, put_k_failu, zapreshchennye_fragmenty, tip_fragmenta)
for nomer_fragmenta = 1:numel(zapreshchennye_fragmenty)
    fragment = zapreshchennye_fragmenty{nomer_fragmenta};
    if contains(tekst, fragment)
        error('%s', sprintf( ...
            'В сценарии %s обнаружено недопустимое %s: %s', ...
            put_k_failu, tip_fragmenta, fragment));
    end
end
end

function zapisi = normalizovat_massiv_zapisei(massiv, imya_polya, put_k_failu, razreshit_pustoi_massiv)
if isempty(massiv)
    if razreshit_pustoi_massiv
        zapisi = {};
        return
    end

    error('%s', sprintf( ...
        'Поле %s не должно быть пустым в сценарии %s.', ...
        imya_polya, put_k_failu));
end

if isstruct(massiv)
    zapisi = num2cell(massiv);
    return
end

if iscell(massiv)
    zapisi = cell(1, numel(massiv));
    for nomer_zapisi = 1:numel(massiv)
        if ~isstruct(massiv{nomer_zapisi})
            error('%s', sprintf( ...
                'Поле %s должно содержать только объекты в сценарии %s.', ...
                imya_polya, put_k_failu));
        end
        zapisi{nomer_zapisi} = massiv{nomer_zapisi};
    end
    return
end

error('%s', sprintf( ...
    'Поле %s должно быть массивом объектов в сценарии %s.', ...
    imya_polya, put_k_failu));
end

function proverit_nalichie_polei(zapis, spisok_polei, imya_zapisi, put_k_failu)
for nomer_polya = 1:numel(spisok_polei)
    imya_polya = spisok_polei{nomer_polya};
    if ~isfield(zapis, imya_polya)
        error('%s', sprintf( ...
            'В записи %s сценария %s отсутствует поле %s.', ...
            imya_zapisi, put_k_failu, imya_polya));
    end
end
end

function proverit_strokovoe_pole(zapis, imya_polya, put_k_failu)
znachenie = zapis.(imya_polya);
if ~(ischar(znachenie) || (isstring(znachenie) && isscalar(znachenie)))
    error('%s', sprintf( ...
        'Поле %s должно быть строкой в сценарии %s.', ...
        imya_polya, put_k_failu));
end

if strlength(strtrim(string(znachenie))) == 0
    error('%s', sprintf( ...
        'Поле %s не должно быть пустой строкой в сценарии %s.', ...
        imya_polya, put_k_failu));
end
end

function proverit_celoe_chislo(znachenie, imya_polya, put_k_failu, razreshit_nol)
if ~(isnumeric(znachenie) && isscalar(znachenie) && isfinite(znachenie) ...
        && floor(znachenie) == znachenie)
    error('%s', sprintf( ...
        'Поле %s должно быть целым числом в сценарии %s.', ...
        imya_polya, put_k_failu));
end

if razreshit_nol
    if znachenie < 0
        error('%s', sprintf( ...
            'Поле %s должно быть неотрицательным в сценарии %s.', ...
            imya_polya, put_k_failu));
    end
elseif znachenie <= 0
    error('%s', sprintf( ...
        'Поле %s должно быть положительным в сценарии %s.', ...
        imya_polya, put_k_failu));
end
end

function proverit_polozhitelnoe_chislo(znachenie, imya_polya, put_k_failu)
if ~(isnumeric(znachenie) && isscalar(znachenie) && isfinite(znachenie) && znachenie > 0)
    error('%s', sprintf( ...
        'Поле %s должно быть положительным числом в сценарии %s.', ...
        imya_polya, put_k_failu));
end
end

function proverit_chislo(znachenie, imya_polya, put_k_failu, razreshit_nol, razreshit_drobnoe)
if ~(isnumeric(znachenie) && isscalar(znachenie) && isfinite(znachenie))
    error('%s', sprintf( ...
        'Поле %s должно быть числом в сценарии %s.', ...
        imya_polya, put_k_failu));
end

if ~razreshit_drobnoe && floor(znachenie) ~= znachenie
    error('%s', sprintf( ...
        'Поле %s должно быть целым числом в сценарии %s.', ...
        imya_polya, put_k_failu));
end

if razreshit_nol
    if znachenie < 0
        error('%s', sprintf( ...
            'Поле %s должно быть неотрицательным числом в сценарии %s.', ...
            imya_polya, put_k_failu));
    end
elseif znachenie <= 0
    error('%s', sprintf( ...
        'Поле %s должно быть положительным числом в сценарии %s.', ...
        imya_polya, put_k_failu));
end
end

function proverit_vektor_iz_treh_komponent(znachenie, imya_polya, put_k_failu)
if ~(isnumeric(znachenie) && numel(znachenie) == 3 && all(isfinite(znachenie(:))))
    error('%s', sprintf( ...
        'Поле %s должно содержать три числовые компоненты в сценарии %s.', ...
        imya_polya, put_k_failu));
end
end

function proverit_granitsy_v_oblasti(granitsy, oblast_poleta, put_k_failu, imya_polya)
granitsy = proverit_oblast_poleta(granitsy, put_k_failu, imya_polya);

if granitsy.xmin < oblast_poleta.xmin || granitsy.xmax > oblast_poleta.xmax ...
        || granitsy.ymin < oblast_poleta.ymin || granitsy.ymax > oblast_poleta.ymax ...
        || granitsy.zmin < oblast_poleta.zmin || granitsy.zmax > oblast_poleta.zmax
    error('%s', sprintf( ...
        'Границы %s выходят за пределы области полета в сценарии %s.', ...
        imya_polya, put_k_failu));
end
end

function rezultat = tochka_v_oblasti(tochka, oblast_poleta)
rezultat = tochka(1) >= oblast_poleta.xmin && tochka(1) <= oblast_poleta.xmax ...
    && tochka(2) >= oblast_poleta.ymin && tochka(2) <= oblast_poleta.ymax ...
    && tochka(3) >= oblast_poleta.zmin && tochka(3) <= oblast_poleta.zmax;
end
