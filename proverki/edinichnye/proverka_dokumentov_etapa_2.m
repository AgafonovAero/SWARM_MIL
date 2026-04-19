function proverka_dokumentov_etapa_2(koren_proekta)
put_k_opisaniyu_scenariev = fullfile( ...
    koren_proekta, 'opyty', 'scenarii', 'OPISANIE_SCENARIEV.md');
put_k_sheme_scenariya = fullfile( ...
    koren_proekta, 'opyty', 'scenarii', 'shema_scenariya.json');
put_k_slovaryu = fullfile(koren_proekta, 'SLOVAR_TERMINOV.md');
put_k_istochnikam = fullfile(koren_proekta, 'istochniki', 'perechen_istochnikov.md');
put_k_dopushcheniyam = fullfile(koren_proekta, 'ZHURNAL_DOPUSCHENII.md');
put_k_izmeneniyam = fullfile(koren_proekta, 'ZHURNAL_IZMENENII.md');

tekst_opisaniya_scenariev = prochitat_dokument(put_k_opisaniyu_scenariev);
tekst_slovarya = prochitat_dokument(put_k_slovaryu);
tekst_istochnikov = prochitat_dokument(put_k_istochnikam);
tekst_dopushcheniy = prochitat_dokument(put_k_dopushcheniyam);
tekst_izmeneniy = prochitat_dokument(put_k_izmeneniyam);
shema_scenariya = prochitat_shemu_scenariya(put_k_sheme_scenariya);

proverit_razdely_opisaniya_scenariev(put_k_opisaniyu_scenariev, tekst_opisaniya_scenariev);
proverit_shemu_scenariya(put_k_sheme_scenariya, shema_scenariya);
proverit_terminy_etapa_2(put_k_slovaryu, tekst_slovarya);
proverit_upominanie_istochnika_etapa_2(put_k_istochnikam, tekst_istochnikov);
proverit_dopushcheniya_etapa_2(put_k_dopushcheniyam, tekst_dopushcheniy);
proverit_zapis_izmeneniy_etapa_2(put_k_izmeneniyam, tekst_izmeneniy);

soobshchenie('Документы этапа 2 содержат обязательные разделы, поля и записи.');
end

function tekst = prochitat_dokument(put_k_failu)
if ~isfile(put_k_failu)
    error('%s', sprintf('Не найден документ этапа 2: %s', put_k_failu));
end

tekst = fileread(put_k_failu);
if strlength(strtrim(string(tekst))) == 0
    error('%s', sprintf('Документ этапа 2 пустой: %s', put_k_failu));
end
end

function shema_scenariya = prochitat_shemu_scenariya(put_k_failu)
if ~isfile(put_k_failu)
    error('%s', sprintf('Не найдена схема сценария этапа 2: %s', put_k_failu));
end

tekst = fileread(put_k_failu);
if strlength(strtrim(string(tekst))) == 0
    error('%s', sprintf('Схема сценария этапа 2 пустая: %s', put_k_failu));
end

try
    shema_scenariya = jsondecode(tekst);
catch oshibka_razbora
    error('%s', sprintf( ...
        'Не удалось разобрать схему сценария %s. Причина: %s', ...
        put_k_failu, oshibka_razbora.message));
end
end

function proverit_razdely_opisaniya_scenariev(put_k_failu, tekst)
obyazatelnye_razdely = {
    'Назначение сценариев'
    'Обязательные поля сценария'
    'Правила задания состава роя'
    'Правила задания области полета'
    'Правила задания препятствий'
    'Правила задания зон запрета'
    'Правила задания целей задания'
    'Правила задания защитных признаков сценария'
    'Правила задания отказов'
    'Правила задания помех связи'
    'Правила фиксации начального числа случайных величин'
    'Правила именования сценариев'
    'Ограничения этапа 2'
    };

for nomer_razdela = 1:numel(obyazatelnye_razdely)
    nazvanie_razdela = obyazatelnye_razdely{nomer_razdela};
    pattern = postroit_shablon_zagolovka({'##'}, nazvanie_razdela, false);

    if ~soderzhit_shablon_zagolovka(tekst, pattern)
        error('%s', sprintf( ...
            'В документе %s отсутствует обязательный раздел: %s', ...
            put_k_failu, nazvanie_razdela));
    end
end
end

function proverit_shemu_scenariya(put_k_failu, shema_scenariya)
obyazatelnye_verhnie_polya = {'versiya_shemy', 'naznachenie', 'obyazatelnye_polya'};
for nomer_polya = 1:numel(obyazatelnye_verhnie_polya)
    imya_polya = obyazatelnye_verhnie_polya{nomer_polya};
    if ~isfield(shema_scenariya, imya_polya)
        error('%s', sprintf( ...
            'В схеме сценария %s отсутствует поле: %s', ...
            put_k_failu, imya_polya));
    end
end

polya_shemy = normalizovat_massiv_obektov( ...
    shema_scenariya.obyazatelnye_polya, put_k_failu, 'obyazatelnye_polya');

imena_polei = cell(1, numel(polya_shemy));
for nomer_polya = 1:numel(polya_shemy)
    tekushchee_pole = polya_shemy{nomer_polya};
    if ~isfield(tekushchee_pole, 'imya')
        error('%s', sprintf( ...
            'В схеме сценария %s у обязательного поля номер %d отсутствует имя.', ...
            put_k_failu, nomer_polya));
    end

    imena_polei{nomer_polya} = char(string(tekushchee_pole.imya));
end

obyazatelnye_polya_scenariya = {
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

for nomer_polya = 1:numel(obyazatelnye_polya_scenariya)
    imya_polya = obyazatelnye_polya_scenariya{nomer_polya};
    if ~ismember(imya_polya, imena_polei)
        error('%s', sprintf( ...
            'В схеме сценария %s отсутствует обязательное поле: %s', ...
            put_k_failu, imya_polya));
    end
end
end

function proverit_terminy_etapa_2(put_k_failu, tekst)
obyazatelnye_terminy = {
    'Паспорт сценария'
    'Состав роя в сценарии'
    'Начальное состояние БВС'
    'Событие отказа'
    'Область действия помехи связи'
    'Ожидаемый показатель сценария'
    'Проектный сценарий'
    };

for nomer_termina = 1:numel(obyazatelnye_terminy)
    termin = obyazatelnye_terminy{nomer_termina};
    blok_termina = poluchit_blok_po_zagolovku(tekst, '##', termin, {'##'});

    if isempty(blok_termina)
        error('%s', sprintf( ...
            'В словаре %s отсутствует термин этапа 2: %s', ...
            put_k_failu, termin));
    end

    proverit_pole_v_bloke(put_k_failu, termin, blok_termina, ...
        'Краткое определение:', 'У термина отсутствует краткое определение');
    proverit_pole_v_bloke(put_k_failu, termin, blok_termina, ...
        'Использование в проекте:', 'У термина отсутствует строка использования');
    proverit_pole_v_bloke(put_k_failu, termin, blok_termina, ...
        'Источник или основание:', 'У термина отсутствует строка источника');
end
end

function proverit_upominanie_istochnika_etapa_2(put_k_failu, tekst)
blok_istochnika = poluchit_blok_po_zagolovku( ...
    tekst, '###', 'OPISANIE_SCENARIEV.md', {'###', '##'});

if isempty(blok_istochnika)
    error('%s', sprintf( ...
        'В перечне источников %s отсутствует документ OPISANIE_SCENARIEV.md.', ...
        put_k_failu));
end

proverit_pole_v_bloke(put_k_failu, 'OPISANIE_SCENARIEV.md', blok_istochnika, ...
    'Наименование:', 'У источника отсутствует строка наименования');
proverit_pole_v_bloke(put_k_failu, 'OPISANIE_SCENARIEV.md', blok_istochnika, ...
    'Назначение в проекте:', 'У источника отсутствует строка назначения');
proverit_pole_v_bloke(put_k_failu, 'OPISANIE_SCENARIEV.md', blok_istochnika, ...
    'Какие разделы проекта на него опираются:', ...
    'У источника отсутствует строка опоры разделов');
end

function proverit_dopushcheniya_etapa_2(put_k_failu, tekst)
obyazatelnye_fragments = {
    'Сценарии этапа 2 задают исходные данные, но не выполняют моделирование.'
    'Начальные скорости на этапе 2 являются только исходными параметрами.'
    'Препятствия и зоны запрета на этапе 2 проверяются только геометрически.'
    'Помехи связи на этапе 2 описываются как будущий расчетный фактор.'
    'Отказы на этапе 2 описываются как будущие события сценария без моделирования последствий.'
    'защитные признаки сценария'
    };

for nomer_fragmenta = 1:numel(obyazatelnye_fragments)
    fragment = obyazatelnye_fragments{nomer_fragmenta};
    if ~contains(lower(tekst), lower(fragment))
        error('%s', sprintf( ...
            'В документе %s отсутствует обязательное допущение этапа 2: %s', ...
            put_k_failu, fragment));
    end
end
end

function proverit_zapis_izmeneniy_etapa_2(put_k_failu, tekst)
if ~soderzhit_shablon_zagolovka(tekst, ...
        postroit_shablon_zagolovka({'##'}, '19.04.2026. Этап 2', false))
    error('%s', sprintf( ...
        'В журнале изменений %s отсутствует запись этапа 2.', ...
        put_k_failu));
end

if ~soderzhit_shablon_zagolovka(tekst, ...
        postroit_shablon_zagolovka({'##'}, '19.04.2026. Исправления качества PR №3', false))
    error('%s', sprintf( ...
        'В журнале изменений %s отсутствует запись о правке PR №3.', ...
        put_k_failu));
end

if ~soderzhit_shablon_zagolovka(tekst, ...
        postroit_shablon_zagolovka( ...
            {'##'}, ...
            '19.04.2026. Восстановление физического формата после a04f116', ...
            false))
    error('%s', sprintf( ...
        ['В журнале изменений %s отсутствует запись о восстановлении ' ...
         'физического формата после a04f116.'], ...
        put_k_failu));
end

if ~soderzhit_shablon_zagolovka(tekst, ...
        postroit_shablon_zagolovka( ...
            {'##'}, ...
            '19.04.2026. Пересборка этапа 2 с чистого состояния', ...
            false))
    error('%s', sprintf( ...
        ['В журнале изменений %s отсутствует запись о пересборке этапа 2 ' ...
         'с чистого состояния.'], ...
        put_k_failu));
end
end

function proverit_pole_v_bloke(put_k_failu, nazvanie_elementa, blok, prefiks, tekst_oshibki)
pattern = ['^' regexptranslate('escape', prefiks) '(?:\s+\S.*)?$'];
est_pole = ~isempty(regexp(blok, pattern, 'once', 'lineanchors'));

if ~est_pole
    error('%s', sprintf( ...
        '%s в документе %s: %s', ...
        tekst_oshibki, put_k_failu, nazvanie_elementa));
end
end

function blok = poluchit_blok_po_zagolovku(tekst, marker_zagolovka, nazvanie, markery_konca)
escaped_name = regexptranslate('escape', nazvanie);
pattern_nachala = sprintf('^%s\\s+%s\\s*$', marker_zagolovka, escaped_name);
stroki = regexp(tekst, '\r\n|\n|\r', 'split');
nomer_nachala = 0;

for nomer_stroki = 1:numel(stroki)
    if ~isempty(regexp(stroki{nomer_stroki}, pattern_nachala, 'once'))
        nomer_nachala = nomer_stroki;
        break
    end
end

if nomer_nachala == 0
    blok = '';
    return
end

nomer_konca = numel(stroki);
for nomer_stroki = (nomer_nachala + 1):numel(stroki)
    if yavlyaetsya_kontsom_bloka(stroki{nomer_stroki}, markery_konca)
        nomer_konca = nomer_stroki - 1;
        break
    end
end

blok = strjoin(stroki((nomer_nachala + 1):nomer_konca), newline);
end

function rezultat = yavlyaetsya_kontsom_bloka(stroka, markery_konca)
rezultat = false;

for nomer_markera = 1:numel(markery_konca)
    marker = regexptranslate('escape', markery_konca{nomer_markera});
    if ~isempty(regexp(stroka, ['^' marker '\s+'], 'once'))
        rezultat = true;
        return
    end
end
end

function pattern = postroit_shablon_zagolovka(markery, nazvanie, razreshit_numeraciyu)
marker_chast = strjoin(markery, '|');
escaped_name = regexptranslate('escape', nazvanie);

if razreshit_numeraciyu
    pattern = sprintf('^(?:%s)\\s+(?:\\d+\\.\\s*)?%s\\s*$', marker_chast, escaped_name);
else
    pattern = sprintf('^(?:%s)\\s+%s\\s*$', marker_chast, escaped_name);
end
end

function rezultat = soderzhit_shablon_zagolovka(tekst, pattern)
rezultat = ~isempty(regexp(tekst, pattern, 'once', 'lineanchors'));
end

function zapisi = normalizovat_massiv_obektov(znachenie, put_k_failu, imya_polya)
if isstruct(znachenie)
    zapisi = num2cell(znachenie);
    return
end

if iscell(znachenie)
    zapisi = cell(1, numel(znachenie));
    for nomer_zapisi = 1:numel(znachenie)
        if ~isstruct(znachenie{nomer_zapisi})
            error('%s', sprintf( ...
                'Поле %s в схеме %s должно содержать только объекты.', ...
                imya_polya, put_k_failu));
        end
        zapisi{nomer_zapisi} = znachenie{nomer_zapisi};
    end
    return
end

error('%s', sprintf( ...
    'Поле %s в схеме %s должно быть массивом объектов.', ...
    imya_polya, put_k_failu));
end
