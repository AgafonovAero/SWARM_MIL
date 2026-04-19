function pult = proverka_pulta_etapa_8(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для проверки пульта исследователя требуется корень проекта.');
end

pult = sozdat_pult_issledovatelya(koren_proekta, false);
ochistka = onCleanup(@() bezopasno_zakryt_okno_pulta(pult));

proverit_vkladki(pult);
proverit_osnovnye_elementy(pult);
proverit_spisok_scenariev(pult);

pult.elementy.scenariya.spisok_scenariev.Value = 'stroi_malyi';
[sostoyanie, ~, dannye_vizualizacii] = vypolnit_raschet_iz_pulta(pult);
pult.sostoyanie = sostoyanie;
pult = obnovit_pult_posle_rascheta(pult);

proverit_dannye_vizualizacii(sostoyanie, dannye_vizualizacii);
proverit_tablicu_itogov(pult);

chislo_kadrov = numel(dannye_vizualizacii.kadry);
srednii_kadr = ceil(chislo_kadrov / 2);

pult.sostoyanie.tekushchii_kadr = 1;
pult = obnovit_pult_posle_rascheta(pult);
pult.sostoyanie.tekushchii_kadr = srednii_kadr;
pult = obnovit_pult_posle_rascheta(pult);
pult.sostoyanie.tekushchii_kadr = chislo_kadrov;
pult = obnovit_pult_posle_rascheta(pult);

proverit_graficheskie_elementy(pult);

clear ochistka
bezopasno_zakryt_okno_pulta(pult);
soobshchenie('Пульт исследователя этапа 8 проверен успешно');
end

function proverit_vkladki(pult)
zagolovki = cellfun(@(pole) pult.vkladki.(pole).Title, ...
    fieldnames(pult.vkladki), 'UniformOutput', false);
obyazatelnye = {
    'Сценарий'
    'Связь'
    'Звенья'
    'Передача'
    'Запуск'
    'Воспроизведение'
    'Показатели'
    'Журнал'
    };

for nomer_vkladki = 1:numel(obyazatelnye)
    if ~any(strcmp(zagolovki, obyazatelnye{nomer_vkladki}))
        error('%s', sprintf( ...
            'В пульте отсутствует обязательная вкладка `%s`.', ...
            obyazatelnye{nomer_vkladki}));
    end
end
end

function proverit_osnovnye_elementy(pult)
if ~isgraphics(pult.okno)
    error('%s', 'Главное окно пульта исследователя не создано.');
end

if ~isgraphics(pult.elementy.zapusk.knopka_zapuska) ...
        || ~isgraphics(pult.elementy.zapusk.tablica_itogov) ...
        || ~isgraphics(pult.elementy.vosproizvedeniya.osi) ...
        || ~isgraphics(pult.elementy.pokazatelei.tablica_pokazatelei)
    error('%s', 'Основные элементы пульта исследователя созданы некорректно.');
end
end

function proverit_spisok_scenariev(pult)
if isempty(pult.sostoyanie.spisok_scenariev)
    error('%s', 'Список сценариев в пульте исследователя пуст.');
end

if ~any(strcmp(pult.elementy.scenariya.spisok_scenariev.Items, 'stroi_malyi'))
    error('%s', ...
        'Сценарий stroi_malyi отсутствует в списке сценариев пульта.');
end
end

function proverit_dannye_vizualizacii(sostoyanie, dannye_vizualizacii)
if isempty(dannye_vizualizacii) || ~isstruct(dannye_vizualizacii)
    error('%s', 'Пульт не сформировал данные визуализации.');
end

if numel(dannye_vizualizacii.kadry) <= 1
    error('%s', ...
        'Для этапа 8 требуется более одного кадра визуализации.');
end

if numel(dannye_vizualizacii.id_bvs) ~= numel(sostoyanie.tekushchii_scenarii.sostav_roya)
    error('%s', ...
        'Число БВС в данных визуализации не совпадает со сценарием.');
end

for nomer_kadra = 1:numel(dannye_vizualizacii.kadry)
    kadr = dannye_vizualizacii.kadry(nomer_kadra);
    if isempty(kadr.polozheniya_bvs) || isempty(kadr.matrica_smeznosti)
        error('%s', sprintf( ...
            'Кадр %d не содержит обязательные данные воспроизведения.', ...
            nomer_kadra));
    end
end

if isempty(sostoyanie.demonstraciya) || isempty(sostoyanie.demonstraciya.peredacha)
    error('%s', ...
        'Пульт не сохранил результат передачи сообщений в состоянии.');
end
end

function proverit_tablicu_itogov(pult)
if isempty(pult.elementy.zapusk.tablica_itogov.Data) ...
        || isempty(pult.elementy.pokazatelei.tablica_pokazatelei.Data)
    error('%s', 'Таблицы итоговых показателей не были заполнены.');
end
end

function proverit_graficheskie_elementy(pult)
if ~isgraphics(pult.elementy.vosproizvedeniya.osi)
    error('%s', 'Ось воспроизведения пульта недействительна.');
end

for nomer_osi = 1:numel(pult.elementy.pokazatelei.osi)
    if ~isgraphics(pult.elementy.pokazatelei.osi(nomer_osi))
        error('%s', sprintf( ...
            'Ось графика показателей %d недействительна.', ...
            nomer_osi));
    end
end
end

function bezopasno_zakryt_okno_pulta(pult)
if isstruct(pult) && isfield(pult, 'okno') && isgraphics(pult.okno)
    delete(pult.okno);
end
end
