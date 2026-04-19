function svodka = proverka_scenariev_etapa_2(koren_proekta)
papka_scenariev = fullfile(koren_proekta, 'opyty', 'scenarii', 'bazovye');
put_k_opisaniyu = fullfile(koren_proekta, 'opyty', 'scenarii', 'OPISANIE_SCENARIEV.md');
put_k_sheme = fullfile(koren_proekta, 'opyty', 'scenarii', 'shema_scenariya.json');

if ~isfolder(papka_scenariev)
    error('%s', sprintf( ...
        'Не найдена папка базовых сценариев: %s', ...
        papka_scenariev));
end

if ~isfile(put_k_opisaniyu)
    error('%s', sprintf( ...
        'Не найдено описание сценариев: %s', ...
        put_k_opisaniyu));
end

if ~isfile(put_k_sheme)
    error('%s', sprintf( ...
        'Не найдена схема сценария: %s', ...
        put_k_sheme));
end

svodka = proverit_vse_scenarii(koren_proekta);

if svodka.kolichestvo_scenariev < 5
    error('%s', 'Количество базовых сценариев этапа 2 должно быть не меньше пяти.');
end

if numel(unique(svodka.identifikatory_scenariev)) ~= numel(svodka.identifikatory_scenariev)
    error('%s', 'Идентификаторы сценариев этапа 2 должны быть уникальны.');
end

if ~svodka.zashchitnye_ogranicheniya_proideny
    error('%s', 'Не все сценарии прошли проверку защитных ограничений.');
end

soobshchenie('Сценарии этапа 2 проверены успешно');
end
