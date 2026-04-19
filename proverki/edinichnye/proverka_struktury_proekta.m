function proverka_struktury_proekta(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('Не задан корень проекта для проверки структуры.');
end

obyazatelnye_papki = {
    'istochniki'
    fullfile('raschet', 'bvs')
    fullfile('raschet', 'roi')
    fullfile('raschet', 'svyaz')
    fullfile('raschet', 'zveno')
    fullfile('raschet', 'upravlenie')
    fullfile('raschet', 'obuchenie')
    fullfile('raschet', 'otsenka')
    fullfile('bloki', 'sozdanie_modelei')
    fullfile('bloki', 'modeli')
    fullfile('opyty', 'scenarii')
    fullfile('opyty', 'zapusk')
    fullfile('opyty', 'rezultaty')
    fullfile('proverki', 'edinichnye')
    fullfile('proverki', 'sistemnye')
    fullfile('otchety', 'risunki')
    fullfile('otchety', 'tablitsy')
    fullfile('otchety', 'protokoly')
    };

obyazatelnye_faily = {
    'OPISANIE.md'
    'TEHNICHESKOE_ZADANIE.md'
    'SLOVAR_TERMINOV.md'
    'ZHURNAL_DOPUSCHENII.md'
    'ZHURNAL_IZMENENII.md'
    fullfile('istochniki', 'perechen_istochnikov.md')
    'zapusk_proverok.m'
    fullfile('proverki', 'edinichnye', 'proverka_struktury_proekta.m')
    fullfile('proverki', 'edinichnye', 'proverka_dokumentov_etapa_1.m')
    fullfile('proverki', 'edinichnye', 'proverka_skrytyh_znakov.m')
    fullfile('raschet', 'otsenka', 'soobshchenie.m')
    };

for nomer_papki = 1:numel(obyazatelnye_papki)
    otnositelnyi_put = obyazatelnye_papki{nomer_papki};
    polnyi_put = fullfile(koren_proekta, otnositelnyi_put);
    if ~isfolder(polnyi_put)
        error('Не найдена обязательная папка: %s', polnyi_put);
    end
end

for nomer_faila = 1:numel(obyazatelnye_faily)
    otnositelnyi_put = obyazatelnye_faily{nomer_faila};
    polnyi_put = fullfile(koren_proekta, otnositelnyi_put);
    if ~isfile(polnyi_put)
        error('Не найден обязательный файл: %s', polnyi_put);
    end
end

soobshchenie('Структура проекта и обязательные документы присутствуют.');
end
