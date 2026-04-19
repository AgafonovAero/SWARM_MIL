function proverka_dokumentov_etapa_1(koren_proekta)
put_k_tz = fullfile(koren_proekta, 'TEHNICHESKOE_ZADANIE.md');
put_k_slovaryu = fullfile(koren_proekta, 'SLOVAR_TERMINOV.md');
put_k_istochnikam = fullfile(koren_proekta, 'istochniki', 'perechen_istochnikov.md');
put_k_dopushcheniyam = fullfile(koren_proekta, 'ZHURNAL_DOPUSCHENII.md');

tekst_tz = prochitat_dokument(put_k_tz);
tekst_slovarya = prochitat_dokument(put_k_slovaryu);
tekst_istochnikov = prochitat_dokument(put_k_istochnikam);
tekst_dopushcheniy = prochitat_dokument(put_k_dopushcheniyam);

proverit_razdely_tz(put_k_tz, tekst_tz);
proverit_terminy_slovarya(put_k_slovaryu, tekst_slovarya);
proverit_istochniki(put_k_istochnikam, tekst_istochnikov);
proverit_razdely_dopushcheniy(put_k_dopushcheniyam, tekst_dopushcheniy);

soobshchenie('Документы этапа 1 содержат обязательные разделы, термины и источники.');
end

function tekst = prochitat_dokument(put_k_failu)
if ~isfile(put_k_failu)
    error('%s', sprintf('Не найден документ: %s', put_k_failu));
end

tekst = fileread(put_k_failu);
if strlength(strtrim(string(tekst))) == 0
    error('%s', sprintf('Документ пустой: %s', put_k_failu));
end
end

function proverit_razdely_tz(put_k_failu, tekst)
obyazatelnye_razdely = {
    'Общие сведения'
    'Цели и назначение разработки'
    'Характеристика объекта моделирования'
    'Требования к системе моделирования'
    'Требования к воспроизводимости'
    'Требования к исходным данным'
    'Требования к результатам'
    'Требования к показателям качества'
    'Требования к журналам опытов'
    'Требования к проверкам'
    'Требования к расширяемости'
    'Требования к ограничениям безопасности моделирования'
    'Требования к математическому обеспечению'
    'Требования к программному обеспечению'
    'Требования к языку и именованию'
    'Требования к информационному обеспечению'
    'Показатели качества'
    'Стадии и этапы работ'
    'Порядок контроля и приемки'
    'Ограничения и допущения'
    'Перечень документов проекта'
    };

for nomer_razdela = 1:numel(obyazatelnye_razdely)
    nazvanie_razdela = obyazatelnye_razdely{nomer_razdela};
    pattern = postroit_shablon_zagolovka({'##', '###'}, nazvanie_razdela, true);

    if ~soderzhit_shablon_zagolovka(tekst, pattern)
        error('%s', sprintf( ...
            'В документе %s отсутствует обязательный раздел: %s', ...
            put_k_failu, nazvanie_razdela));
    end
end
end

function proverit_terminy_slovarya(put_k_failu, tekst)
obyazatelnye_terminy = {
    'БВС'
    'Беспилотная авиационная система'
    'Рой БВС'
    'Сеть роя БВС'
    'Участник роя'
    'Звено роя'
    'Головной БВС'
    'Участник звена'
    'Связность'
    'Граф связности'
    'Линия связи'
    'Полезность линии связи'
    'Соседний БВС'
    'Область полета'
    'Зона запрета'
    'Препятствие'
    'Цель задания'
    'Сценарий опыта'
    'Начальное число случайных величин'
    'Отказ БВС'
    'Помеха связи'
    'Задержка передачи'
    'Доля доставленных сообщений'
    'Расход энергии'
    'Удержание строя'
    'Избегание столкновений'
    'Роевое управление'
    'Устойчивость роя'
    'Распределение задач'
    'Распределение ресурсов'
    'Распределенное обучение'
    'Смысловая передача сведений'
    'Гарантированная по времени передача сведений'
    'Показатель качества'
    'Протокол опыта'
    };

for nomer_termina = 1:numel(obyazatelnye_terminy)
    termin = obyazatelnye_terminy{nomer_termina};
    blok_termina = poluchit_blok_po_zagolovku(tekst, '##', termin, {'##'});

    if isempty(blok_termina)
        error('%s', sprintf( ...
            'В словаре %s отсутствует обязательный термин: %s', ...
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

function proverit_istochniki(put_k_failu, tekst)
obyazatelnye_razdely = {
    'Нормативные источники'
    'Научные источники'
    'Сведения о расчетной и блочной среде'
    'Внутренние документы проекта'
    };

for nomer_razdela = 1:numel(obyazatelnye_razdely)
    nazvanie_razdela = obyazatelnye_razdely{nomer_razdela};
    pattern = postroit_shablon_zagolovka({'##'}, nazvanie_razdela, false);

    if ~soderzhit_shablon_zagolovka(tekst, pattern)
        error('%s', sprintf( ...
            'В перечне источников %s отсутствует обязательный раздел: %s', ...
            put_k_failu, nazvanie_razdela));
    end
end

obyazatelnye_istochniki = {
    'ГОСТ Р 57258-2016. Системы беспилотные авиационные. Термины и определения'
    'ГОСТ 34.602-2020. Техническое задание на создание автоматизированной системы'
    'ГОСТ 19.201-78. Техническое задание. Требования к содержанию и оформлению'
    'UAV Swarm Cooperation : A Networking Perspective'
    'MATLAB Release Notes'
    'Simulink Release Notes'
    };

for nomer_istochnika = 1:numel(obyazatelnye_istochniki)
    nazvanie_istochnika = obyazatelnye_istochniki{nomer_istochnika};
    blok_istochnika = poluchit_blok_po_zagolovku(tekst, '###', nazvanie_istochnika, {'###', '##'});

    if isempty(blok_istochnika)
        error('%s', sprintf( ...
            'В перечне источников %s отсутствует обязательный источник: %s', ...
            put_k_failu, nazvanie_istochnika));
    end

    proverit_pole_v_bloke(put_k_failu, nazvanie_istochnika, blok_istochnika, ...
        'Наименование:', 'У источника отсутствует строка наименования');
    proverit_pole_v_bloke(put_k_failu, nazvanie_istochnika, blok_istochnika, ...
        'Назначение в проекте:', 'У источника отсутствует строка назначения');
    proverit_pole_v_bloke(put_k_failu, nazvanie_istochnika, blok_istochnika, ...
        'Какие разделы проекта на него опираются:', ...
        'У источника отсутствует строка опоры разделов');
end
end

function proverit_razdely_dopushcheniy(put_k_failu, tekst)
obyazatelnye_razdely = {
    'Принятые допущения'
    'Еще не проверенные допущения'
    'Ограничения применимости'
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
