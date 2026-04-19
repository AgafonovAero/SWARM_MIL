function spisok_putei = spisok_scenariev(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Не задан корень проекта для получения списка сценариев.');
end

papka_scenariev = fullfile(koren_proekta, 'opyty', 'scenarii', 'bazovye');
if ~isfolder(papka_scenariev)
    error('%s', sprintf( ...
        'Не найдена папка базовых сценариев: %s', ...
        papka_scenariev));
end

naidennye_faily = dir(fullfile(papka_scenariev, '*.json'));
if isempty(naidennye_faily)
    error('%s', sprintf( ...
        'В папке сценариев не найдено ни одного JSON-файла: %s', ...
        papka_scenariev));
end

spisok_putei = cell(1, numel(naidennye_faily));
for nomer_faila = 1:numel(naidennye_faily)
    spisok_putei{nomer_faila} = fullfile( ...
        naidennye_faily(nomer_faila).folder, ...
        naidennye_faily(nomer_faila).name);
end

spisok_putei = sort(spisok_putei);
end
