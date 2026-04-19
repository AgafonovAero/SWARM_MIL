function proverka_struktury_proekta(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Не задан корень проекта для проверки структуры.');
end

obyazatelnye_papki = {
    'apps'
    'istochniki'
    fullfile('raschet', 'bvs')
    fullfile('raschet', 'roi')
    fullfile('raschet', 'sreda')
    fullfile('raschet', 'svyaz')
    fullfile('raschet', 'zveno')
    fullfile('raschet', 'peredacha')
    fullfile('raschet', 'opyty')
    fullfile('raschet', 'upravlenie')
    fullfile('raschet', 'obuchenie')
    fullfile('raschet', 'otsenka')
    fullfile('raschet', 'scenarii')
    'visualization'
    'bloki'
    fullfile('bloki', 'generated')
    fullfile('bloki', 'sozdanie_modelei')
    fullfile('bloki', 'modeli')
    fullfile('opyty', 'scenarii')
    fullfile('opyty', 'scenarii', 'bazovye')
    fullfile('opyty', 'serii')
    fullfile('opyty', 'zapusk')
    fullfile('opyty', 'rezultaty')
    fullfile('proverki', 'edinichnye')
    fullfile('proverki', 'sistemnye')
    fullfile('otchety', 'risunki')
    fullfile('otchety', 'serii')
    fullfile('otchety', 'tablitsy')
    fullfile('otchety', 'protokoly')
    };

obyazatelnye_faily = {
    '.gitignore'
    'README.md'
    'OPISANIE.md'
    'TEHNICHESKOE_ZADANIE.md'
    'SLOVAR_TERMINOV.md'
    'ZHURNAL_DOPUSCHENII.md'
    'ZHURNAL_IZMENENII.md'
    'zapusk_proverok.m'
    'zapusk_demonstratora_roya.m'
    'zapusk_pulta_issledovatelya.m'
    'zapusk_simulink_stenda_roya.m'
    fullfile('istochniki', 'perechen_istochnikov.md')
    fullfile('opyty', 'scenarii', 'OPISANIE_SCENARIEV.md')
    fullfile('opyty', 'scenarii', 'shema_scenariya.json')
    fullfile('proverki', 'edinichnye', 'proverka_struktury_proekta.m')
    fullfile('proverki', 'edinichnye', 'proverka_dokumentov_etapa_1.m')
    fullfile('proverki', 'edinichnye', 'proverka_dokumentov_etapa_2.m')
    fullfile('proverki', 'edinichnye', 'proverka_skrytyh_znakov.m')
    fullfile('proverki', 'edinichnye', ...
        'proverka_fizicheskogo_formata_tekstov.m')
    fullfile('proverki', 'edinichnye', 'proverka_razmetki_markdown.m')
    fullfile('proverki', 'edinichnye', 'proverka_scenariev_etapa_2.m')
    fullfile('proverki', 'edinichnye', 'proverka_kinematiki_etapa_3.m')
    fullfile('proverki', 'edinichnye', 'proverka_svyazi_etapa_4.m')
    fullfile('proverki', 'edinichnye', 'proverka_zvenev_etapa_5.m')
    fullfile('proverki', 'edinichnye', 'proverka_peredachi_etapa_6.m')
    fullfile('proverki', 'edinichnye', 'proverka_vizualizacii_etapa_7.m')
    fullfile('proverki', 'edinichnye', 'proverka_pulta_etapa_8.m')
    fullfile('proverki', 'edinichnye', ...
        'proverka_simulink_stenda_etapa_9.m')
    fullfile('proverki', 'edinichnye', ...
        'proverka_serii_opytov_etapa_10.m')
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
    fullfile('raschet', 'svyaz', 'OPISANIE_SVYAZI.md')
    fullfile('raschet', 'svyaz', 'parametry_svyazi_po_umolchaniyu.m')
    fullfile('raschet', 'svyaz', 'proverit_parametry_svyazi.m')
    fullfile('raschet', 'svyaz', 'raschet_matricy_rasstoyanii.m')
    fullfile('raschet', 'svyaz', 'otsenit_liniyu_svyazi.m')
    fullfile('raschet', 'svyaz', 'postroit_graf_svyaznosti.m')
    fullfile('raschet', 'svyaz', 'raschet_svyaznosti_po_kinematike.m')
    fullfile('raschet', 'zveno', 'OPISANIE_ZVENEV.md')
    fullfile('raschet', 'zveno', 'parametry_zvenev_po_umolchaniyu.m')
    fullfile('raschet', 'zveno', 'proverit_parametry_zvenev.m')
    fullfile('raschet', 'zveno', 'sformirovat_zvenya_po_grafu.m')
    fullfile('raschet', 'zveno', 'vybrat_golovnoi_bvs.m')
    fullfile('raschet', 'zveno', 'naznachit_golovnye_bvs.m')
    fullfile('raschet', 'zveno', 'otsenit_zvenya.m')
    fullfile('raschet', 'zveno', 'raschet_zvenev_po_svyaznosti.m')
    fullfile('raschet', 'peredacha', 'OPISANIE_PEREDACHI.md')
    fullfile('raschet', 'peredacha', ...
        'parametry_peredachi_po_umolchaniyu.m')
    fullfile('raschet', 'peredacha', 'proverit_parametry_peredachi.m')
    fullfile('raschet', 'peredacha', 'sozdat_soobshchenie.m')
    fullfile('raschet', 'peredacha', 'sozdat_nachalnye_soobshcheniya.m')
    fullfile('raschet', 'peredacha', 'sozdat_ocheredi_bvs.m')
    fullfile('raschet', 'peredacha', 'dobavit_soobshchenie_v_ochered.m')
    fullfile('raschet', 'peredacha', 'vybrat_sleduyushchii_bvs.m')
    fullfile('raschet', 'peredacha', 'vypolnit_shag_peredachi.m')
    fullfile('raschet', 'peredacha', 'raschet_peredachi_po_trasse.m')
    fullfile('raschet', 'peredacha', 'otsenit_peredachu.m')
    fullfile('raschet', 'opyty', 'zagruzit_plan_serii_opytov.m')
    fullfile('raschet', 'opyty', 'proverit_plan_serii_opytov.m')
    fullfile('raschet', 'opyty', 'sozdat_varianty_serii_opytov.m')
    fullfile('raschet', 'opyty', 'vypolnit_odin_opyt.m')
    fullfile('raschet', 'opyty', 'izvlech_pokazateli_opyta.m')
    fullfile('raschet', 'opyty', 'vypolnit_seriyu_opytov.m')
    fullfile('raschet', 'opyty', 'sravnit_rezultaty_serii.m')
    fullfile('raschet', 'opyty', 'sohranit_rezultaty_serii.m')
    fullfile('visualization', 'OPISANIE_VIZUALIZACII.md')
    fullfile('visualization', 'sobrat_dannye_demonstracii_roya.m')
    fullfile('visualization', 'podgotovit_dannye_vizualizacii.m')
    fullfile('visualization', 'postroit_scenu_roya_3d.m')
    fullfile('visualization', 'obnovit_kadr_roya.m')
    fullfile('visualization', 'postroit_grafiki_pokazatelei.m')
    fullfile('visualization', 'postroit_grafiki_serii_opytov.m')
    fullfile('visualization', 'sohranit_kadr_roya.m')
    fullfile('visualization', 'sohranit_animaciyu_roya.m')
    fullfile('visualization', 'sohranit_otchet_demonstracii.m')
    fullfile('raschet', 'scenarii', 'zagruzit_scenarii.m')
    fullfile('raschet', 'scenarii', 'spisok_scenariev.m')
    fullfile('raschet', 'scenarii', 'proverit_scenarii.m')
    fullfile('raschet', 'scenarii', 'proverit_vse_scenarii.m')
    fullfile('apps', 'OPISANIE_PULTA_ISSLEDOVATELYA.md')
    fullfile('apps', 'sozdat_pult_issledovatelya.m')
    fullfile('apps', 'sozdat_sostoyanie_pulta.m')
    fullfile('apps', 'zapolnit_vkladku_scenariya.m')
    fullfile('apps', 'zapolnit_vkladku_svyazi.m')
    fullfile('apps', 'zapolnit_vkladku_zvenev.m')
    fullfile('apps', 'zapolnit_vkladku_peredachi.m')
    fullfile('apps', 'zapolnit_vkladku_zapuska.m')
    fullfile('apps', 'zapolnit_vkladku_vosproizvedeniya.m')
    fullfile('apps', 'zapolnit_vkladku_pokazatelei.m')
    fullfile('apps', 'zapolnit_vkladku_zhurnala.m')
    fullfile('apps', 'vypolnit_raschet_iz_pulta.m')
    fullfile('apps', 'obnovit_pult_posle_rascheta.m')
    fullfile('apps', 'poluchit_parametry_iz_pulta.m')
    fullfile('apps', 'proverit_parametry_pulta.m')
    fullfile('apps', 'dobavit_zapis_v_zhurnal_pulta.m')
    fullfile('bloki', 'OPISANIE_SIMULINK_STENDA.md')
    fullfile('bloki', 'sozdanie_modelei', 'sozdat_model_stenda_roya.m')
    fullfile('bloki', 'sozdanie_modelei', ...
        'podgotovit_parametry_simulink_stenda.m')
    fullfile('bloki', 'sozdanie_modelei', ...
        'vypolnit_raschet_iz_simulink_stenda.m')
    fullfile('bloki', 'sozdanie_modelei', 'otkryt_model_stenda_roya.m')
    fullfile('opyty', 'serii', 'OPISANIE_SERII_OPYTOV.md')
    fullfile('opyty', 'serii', 'malaya_seriya_stroi_i_svyaz.json')
    };

proverit_papki(koren_proekta, obyazatelnye_papki);
proverit_faily(koren_proekta, obyazatelnye_faily);

soobshchenie( ...
    'Структура проекта и обязательные документы присутствуют.');
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
