function proverka_dokumentov_etapa_1(koren_proekta)
put_k_tz = fullfile(koren_proekta, 'TEHNICHESKOE_ZADANIE.md');
put_k_slovaryu = fullfile(koren_proekta, 'SLOVAR_TERMINOV.md');
put_k_istochnikam = fullfile(koren_proekta, 'istochniki', 'perechen_istochnikov.md');
put_k_dopushcheniyam = fullfile(koren_proekta, 'ZHURNAL_DOPUSCHENII.md');

tekst_tz = prochitat_dokument(put_k_tz);
tekst_slovarya = prochitat_dokument(put_k_slovaryu);
tekst_istochnikov = prochitat_dokument(put_k_istochnikam);
tekst_dopushcheniy = prochitat_dokument(put_k_dopushcheniyam);

obyazatelnye_razdely_tz = {
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
    'Требования к информационному обеспечению'
    'Показатели качества'
    'Стадии и этапы работ'
    'Порядок контроля и приемки'
    'Ограничения и допущения'
    'Перечень документов проекта'
    };

obyazatelnye_razdely_slovarya = {
    'Словарь терминов'
    };

obyazatelnye_razdely_istochnikov = {
    'Нормативные источники'
    'Научные источники'
    'Сведения о расчетной и блочной среде'
    'Внутренние документы проекта'
    };

obyazatelnye_razdely_dopushcheniy = {
    'Принятые допущения'
    'Еще не проверенные допущения'
    'Ограничения применимости'
    };

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

obyazatelnye_istochniki = {
    'ГОСТ Р 57258-2016'
    'ГОСТ 34.602-2020'
    'ГОСТ 19.201-78'
    'UAV Swarm Cooperation : A Networking Perspective'
    'MATLAB Release Notes'
    'Simulink Release Notes'
    };

proverit_razdely(put_k_tz, tekst_tz, obyazatelnye_razdely_tz);
proverit_razdely(put_k_slovaryu, tekst_slovarya, obyazatelnye_razdely_slovarya);
proverit_razdely(put_k_istochnikam, tekst_istochnikov, obyazatelnye_razdely_istochnikov);
proverit_razdely(put_k_dopushcheniyam, tekst_dopushcheniy, obyazatelnye_razdely_dopushcheniy);
proverit_terminy(put_k_slovaryu, tekst_slovarya, obyazatelnye_terminy);
proverit_istochniki(put_k_istochnikam, tekst_istochnikov, obyazatelnye_istochniki);

soobshchenie('Документы этапа 1 содержат обязательные разделы, термины и источники.');
end

function tekst = prochitat_dokument(put_k_failu)
if ~isfile(put_k_failu)
    error('Не найден документ: %s', put_k_failu);
end

tekst = fileread(put_k_failu);
if strlength(strtrim(string(tekst))) == 0
    error('Документ пустой: %s', put_k_failu);
end
end

function proverit_razdely(put_k_failu, tekst, obyazatelnye_razdely)
for nomer_razdela = 1:numel(obyazatelnye_razdely)
    nazvanie_razdela = obyazatelnye_razdely{nomer_razdela};
    if ~contains(tekst, nazvanie_razdela)
        error('Отсутствует обязательный раздел в документе %s: %s', put_k_failu, nazvanie_razdela);
    end
end
end

function proverit_terminy(put_k_failu, tekst, obyazatelnye_terminy)
for nomer_termina = 1:numel(obyazatelnye_terminy)
    termin = obyazatelnye_terminy{nomer_termina};
    zagolovok = ['## ' termin];
    if ~contains(tekst, zagolovok)
        error('Отсутствует обязательный термин в словаре %s: %s', put_k_failu, termin);
    end
end
end

function proverit_istochniki(put_k_failu, tekst, obyazatelnye_istochniki)
for nomer_istochnika = 1:numel(obyazatelnye_istochniki)
    istochnik = obyazatelnye_istochniki{nomer_istochnika};
    if ~contains(tekst, istochnik)
        error('Отсутствует обязательный источник в перечне источников %s: %s', put_k_failu, istochnik);
    end
end
end
