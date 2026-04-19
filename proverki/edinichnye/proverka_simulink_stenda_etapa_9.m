function rezultat = proverka_simulink_stenda_etapa_9(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для проверки Simulink-представления требуется корень проекта.');
end

proverit_dostupnost_simulink();

[put_k_modeli, imya_modeli] = sozdat_model_stenda_roya( ...
    koren_proekta, ...
    false, ...
    true);
ochistka = onCleanup(@() bezopasno_zakryt_model(imya_modeli));

if ~isfile(put_k_modeli)
    error('%s', sprintf( ...
        'После построения не найден файл модели: %s', ...
        put_k_modeli));
end

load_system(put_k_modeli);
open_system(imya_modeli);

proverit_verhnie_podsistemy(imya_modeli);
proverit_osnovnye_soedineniya(imya_modeli);
proverit_annotacii(imya_modeli);

parametry = podgotovit_parametry_simulink_stenda(koren_proekta, 'stroi_malyi');
rezultat = vypolnit_raschet_iz_simulink_stenda(koren_proekta, parametry);
proverit_rezultat_rascheta(rezultat);

clear ochistka
bezopasno_zakryt_model(imya_modeli);
soobshchenie('Simulink-представление этапа 9 проверено успешно');
end

function proverit_dostupnost_simulink()
if isempty(ver('Simulink')) || ~license('test', 'Simulink')
    error('%s', ...
        'Simulink недоступен. Проверка этапа 9 не может быть выполнена.');
end
end

function proverit_verhnie_podsistemy(imya_modeli)
obyazatelnye_nazvaniya = { ...
    'Сценарий'
    'Кинематика'
    'Связность'
    'Звенья'
    'Передача'
    'Визуализация'
    'Оценка'
    'Параметры'
    'Журнал'
    };

puti_podsistem = find_system( ...
    imya_modeli, ...
    'SearchDepth', 1, ...
    'BlockType', 'SubSystem');
nazvaniya = cell(size(puti_podsistem));

for nomer_podsistemy = 1:numel(puti_podsistem)
    nazvaniya{nomer_podsistemy} = get_param( ...
        puti_podsistem{nomer_podsistemy}, ...
        'Name');
end

for nomer_nazvaniya = 1:numel(obyazatelnye_nazvaniya)
    if ~any(strcmp(nazvaniya, obyazatelnye_nazvaniya{nomer_nazvaniya}))
        error('%s', sprintf( ...
            'В модели отсутствует подсистема `%s`.', ...
            obyazatelnye_nazvaniya{nomer_nazvaniya}));
    end
end
end

function proverit_osnovnye_soedineniya(imya_modeli)
ozhidaemye_pary = { ...
    'Сценарий', 'Кинематика'
    'Кинематика', 'Связность'
    'Связность', 'Звенья'
    'Звенья', 'Передача'
    'Передача', 'Визуализация'
    'Визуализация', 'Оценка'
    };

linii = find_system( ...
    imya_modeli, ...
    'FindAll', 'on', ...
    'SearchDepth', 1, ...
    'Type', 'line');

if isempty(linii)
    error('%s', ...
        'В модели отсутствуют соединения между основными подсистемами.');
end

fakticheskie_pary = cell(0, 2);
for nomer_linii = 1:numel(linii)
    ishodnyi_blok = get_param(linii(nomer_linii), 'SrcBlockHandle');
    konechnye_bloki = get_param(linii(nomer_linii), 'DstBlockHandle');

    if ishodnyi_blok == -1 || isempty(konechnye_bloki)
        continue
    end

    imya_ishodnogo = get_param(ishodnyi_blok, 'Name');
    for nomer_konechnogo = 1:numel(konechnye_bloki)
        fakticheskie_pary(end + 1, :) = { ...
            imya_ishodnogo, ...
            get_param(konechnye_bloki(nomer_konechnogo), 'Name') ...
            }; %#ok<AGROW>
    end
end

for nomer_pary = 1:size(ozhidaemye_pary, 1)
    est_para = any(strcmp(fakticheskie_pary(:, 1), ozhidaemye_pary{nomer_pary, 1}) ...
        & strcmp(fakticheskie_pary(:, 2), ozhidaemye_pary{nomer_pary, 2}));
    if ~est_para
        error('%s', sprintf( ...
            'В модели отсутствует соединение `%s -> %s`.', ...
            ozhidaemye_pary{nomer_pary, 1}, ...
            ozhidaemye_pary{nomer_pary, 2}));
    end
end
end

function proverit_annotacii(imya_modeli)
annotacii = find_system( ...
    imya_modeli, ...
    'FindAll', 'on', ...
    'Type', 'annotation');

if isempty(annotacii)
    error('%s', 'В Simulink-модели отсутствуют русские аннотации.');
end

est_russkaya_annotaciya = false;
for nomer_annotacii = 1:numel(annotacii)
    tekst = poluchit_tekst_annotacii(annotacii(nomer_annotacii));
    if ~isempty(regexp(tekst, '[А-Яа-яЁё]', 'once'))
        est_russkaya_annotaciya = true;
        break
    end
end

if ~est_russkaya_annotaciya
    error('%s', 'В Simulink-модели не найдены русские аннотации.');
end
end

function tekst = poluchit_tekst_annotacii(annotaciya)
tekst = '';
try
    tekst = get_param(annotaciya, 'Text');
catch
    try
        tekst = get_param(annotaciya, 'Name');
    catch
        tekst = '';
    end
end
end

function proverit_rezultat_rascheta(rezultat)
obyazatelnye_polya = { ...
    'kinematika'
    'svyaznost'
    'zvenya'
    'peredacha'
    'vizualizaciya'
    };

if ~isstruct(rezultat)
    error('%s', ...
        'Расчет из Simulink-представления должен возвращать структуру.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat, imya_polya) || isempty(rezultat.(imya_polya))
        error('%s', sprintf( ...
            'В результате Simulink-стенда отсутствует поле %s.', ...
            imya_polya));
    end
end
end

function bezopasno_zakryt_model(imya_modeli)
if bdIsLoaded(imya_modeli)
    close_system(imya_modeli, 0);
end
end
