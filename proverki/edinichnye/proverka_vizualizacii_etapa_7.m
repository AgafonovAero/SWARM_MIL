function demonstraciya = proverka_vizualizacii_etapa_7(koren_proekta)
demonstraciya = sobrat_dannye_demonstracii_roya(koren_proekta, 'stroi_malyi');
dannye_vizualizacii = podgotovit_dannye_vizualizacii(demonstraciya);

proverit_chislo_kadrov(dannye_vizualizacii);
proverit_chislo_bvs(demonstraciya, dannye_vizualizacii);
proverit_kadry(dannye_vizualizacii);
proverit_rezultat_peredachi(dannye_vizualizacii);

grafika = postroit_scenu_roya_3d(dannye_vizualizacii, false);
grafiki = postroit_grafiki_pokazatelei(dannye_vizualizacii, false);
ochistka = onCleanup(@() zakryt_figury(grafika, grafiki));

srednii_kadr = ceil(numel(dannye_vizualizacii.kadry) / 2);
grafika = obnovit_kadr_roya(grafika, dannye_vizualizacii, 1);
grafika = obnovit_kadr_roya(grafika, dannye_vizualizacii, srednii_kadr);
grafika = obnovit_kadr_roya( ...
    grafika, ...
    dannye_vizualizacii, ...
    numel(dannye_vizualizacii.kadry));

proverit_graficheskie_deskriptory(grafika, grafiki);

clear ochistka
zakryt_figury(grafika, grafiki);
soobshchenie('Визуализация этапа 7 проверена успешно');
end

function proverit_chislo_kadrov(dannye_vizualizacii)
if numel(dannye_vizualizacii.kadry) <= 1
    error('%s', 'Для визуализации этапа 7 требуется более одного кадра.');
end
end

function proverit_chislo_bvs(demonstraciya, dannye_vizualizacii)
chislo_bvs_v_scenarii = numel(demonstraciya.scenarii.sostav_roya);
if numel(dannye_vizualizacii.id_bvs) ~= chislo_bvs_v_scenarii
    error('%s', [ ...
        'Число БВС в данных визуализации не совпадает с числом БВС ' ...
        'в сценарии.' ...
        ]);
end
end

function proverit_kadry(dannye_vizualizacii)
chislo_bvs = numel(dannye_vizualizacii.id_bvs);

for nomer_kadra = 1:numel(dannye_vizualizacii.kadry)
    kadr = dannye_vizualizacii.kadry(nomer_kadra);

    if ~isfield(kadr, 'polozheniya_bvs') ...
            || ~isequal(size(kadr.polozheniya_bvs), [chislo_bvs, 3])
        error('%s', sprintf( ...
            'Кадр %d не содержит корректные положения БВС.', ...
            nomer_kadra));
    end

    if ~isfield(kadr, 'matrica_smeznosti') ...
            || ~isequal(size(kadr.matrica_smeznosti), [chislo_bvs, chislo_bvs])
        error('%s', sprintf( ...
            'Кадр %d не содержит корректную матрицу смежности.', ...
            nomer_kadra));
    end

    if ~isfield(kadr, 'zvenya')
        error('%s', sprintf( ...
            'Кадр %d не содержит данные звеньев.', ...
            nomer_kadra));
    end
end
end

function proverit_rezultat_peredachi(dannye_vizualizacii)
if ~isfield(dannye_vizualizacii, 'peredacha') ...
        || ~isstruct(dannye_vizualizacii.peredacha)
    error('%s', ...
        'В данных визуализации отсутствует результат передачи сообщений.');
end
end

function proverit_graficheskie_deskriptory(grafika, grafiki)
if ~isgraphics(grafika.figura) || ~isgraphics(grafika.osi)
    error('%s', 'Трехмерная сцена этапа 7 создана некорректно.');
end

if ~isgraphics(grafika.tochki_bvs) || ~isgraphics(grafika.golovnye_bvs)
    error('%s', 'Основные графические объекты сцены невалидны.');
end

if ~isgraphics(grafiki.figura)
    error('%s', 'Фигура графиков показателей не создана.');
end

for nomer_osi = 1:numel(grafiki.osi)
    if ~isgraphics(grafiki.osi(nomer_osi))
        error('%s', sprintf( ...
            'Ось графика показателей %d невалидна.', ...
            nomer_osi));
    end
end
end

function zakryt_figury(grafika, grafiki)
if isstruct(grafika) && isfield(grafika, 'figura') && isgraphics(grafika.figura)
    close(grafika.figura);
end

if isstruct(grafiki) && isfield(grafiki, 'figura') && isgraphics(grafiki.figura)
    close(grafiki.figura);
end
end
