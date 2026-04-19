function proverka_struktury_proekta(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Не задан корень проекта для проверки структуры.');
end

obyazatelnye_papki = {
    'istochniki'
    fullfile('raschet', 'bvs')
    fullfile('raschet', 'roi')
    fullfile('raschet', 'sreda')
    fullfile('raschet', 'svyaz')
    fullfile('raschet', 'zveno')
    fullfile('raschet', 'upravlenie')
    fullfile('raschet', 'obuchenie')
    fullfile('raschet', 'otsenka')
    fullfile('raschet', 'scenarii')
    fullfile('bloki', 'sozdanie_modelei')
    fullfile('bloki', 'modeli')
    fullfile('opyty', 'scenarii')
    fullfile('opyty', 'scenarii', 'bazovye')
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
    fullfile('opyty', 'scenarii', 'OPISANIE_SCENARIEV.md')
    fullfile('opyty', 'scenarii', 'shema_scenariya.json')
    fullfile('proverki', 'edinichnye', 'proverka_struktury_proekta.m')
    fullfile('proverki', 'edinichnye', 'proverka_dokumentov_etapa_1.m')
    fullfile('proverki', 'edinichnye', 'proverka_dokumentov_etapa_2.m')
    fullfile('proverki', 'edinichnye', 'proverka_skrytyh_znakov.m')
    fullfile('proverki', 'edinichnye', 'proverka_fizicheskogo_formata_tekstov.m')
    fullfile('proverki', 'edinichnye', 'proverka_razmetki_markdown.m')
    fullfile('proverki', 'edinichnye', 'proverka_scenariev_etapa_2.m')
    fullfile('proverki', 'edinichnye', 'proverka_kinematiki_etapa_3.m')
    fullfile('raschet', 'otsenka', 'soobshchenie.m')
    fullfile('raschet', 'bvs', 'OPISANIE_KINEMATIKI.md')
    fullfile('raschet', 'bvs', 'sozdat_sostoyanie_bvs_iz_scenariya.m')
    fullfile('raschet', 'bvs', 'proverit_sostoyanie_bvs.m')
    fullfile('raschet', 'bvs', 'shag_kinematiki_bvs.m')
    fullfile('raschet', 'bvs', 'shag_kinematiki_roya.m')
    fullfile('raschet', 'bvs', 'raschet_passivnoi_kinematiki.m')
    fullfile('raschet', 'sreda', 'proverit_oblast_poleta.m')
    fullfile('raschet', 'sreda', 'tochka_v_oblasti_poleta.m')
    fullfile('raschet', 'sreda', 'otrazit_tochku_ot_granic.m')
    fullfile('raschet', 'scenarii', 'zagruzit_scenarii.m')
    fullfile('raschet', 'scenarii', 'spisok_scenariev.m')
    fullfile('raschet', 'scenarii', 'proverit_scenarii.m')
    fullfile('raschet', 'scenarii', 'proverit_vse_scenarii.m')
    };

proverit_papki(koren_proekta, obyazatelnye_papki);
proverit_faily(koren_proekta, obyazatelnye_faily);

soobshchenie('Структура проекта и обязательные документы присутствуют.');
end

function proverit_papki(koren_proekta, obyazatelnye_papki)
for nomer_papki = 1:numel(obyazatelnye_papki)
    otnositelnyi_put = obyazatelnye_papki{nomer_papki};
    polnyi_put = fullfile(koren_proekta, otnositelnyi_put);

    if ~isfolder(polnyi_put)
        error('%s', sprintf( ...
            'Не найдена обязательная папка: %s', ...
            polnyi_put));
    end
end
end

function proverit_faily(koren_proekta, obyazatelnye_faily)
for nomer_faila = 1:numel(obyazatelnye_faily)
    otnositelnyi_put = obyazatelnye_faily{nomer_faila};
    polnyi_put = fullfile(koren_proekta, otnositelnyi_put);

    if ~isfile(polnyi_put)
        error('%s', sprintf( ...
            'Не найден обязательный файл: %s', ...
            polnyi_put));
    end
end
end
